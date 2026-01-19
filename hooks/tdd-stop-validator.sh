#!/bin/bash
# Stop hook for TDD discipline enforcement
# Validates that user isn't stopping in the middle of an incomplete TDD cycle

set -euo pipefail

# Helper function to approve stopping
approve_stop() {
    local message="${1:-}"
    jq -n --arg msg "$message" '{
        "decision": "approve",
        "systemMessage": $msg
    }'
    exit 0
}

# Helper function to block stopping
block_stop() {
    local reason="$1"
    local message="${2:-}"
    jq -n --arg reason "$reason" --arg msg "$message" '{
        "decision": "block",
        "reason": $reason,
        "systemMessage": $msg
    }' >&2
    exit 2
}

# Read input from stdin
input=$(cat)

# Extract working directory
cwd=$(echo "$input" | jq -r '.cwd // ""')

if [ -z "$cwd" ]; then
    approve_stop ""
fi

# Check if TDD session exists
session_file="$cwd/.tdd-session.json"

if [ ! -f "$session_file" ]; then
    # No active TDD session, allow stopping
    approve_stop ""
fi

# Validate session file is valid JSON
if ! jq empty "$session_file" 2>/dev/null; then
    approve_stop "⚠️ Warning: .tdd-session.json is corrupted. Allowing stop but consider cleaning up the session file."
fi

# Read session data
phase=$(jq -r '.phase // "unknown"' "$session_file" 2>/dev/null)
kata_name=$(jq -r '.kata.name // "Unknown Kata"' "$session_file" 2>/dev/null)

# Check git status to see if there are uncommitted changes
cd "$cwd" 2>/dev/null || approve_stop ""

uncommitted_changes=false
if git rev-parse --git-dir > /dev/null 2>&1; then
    # Check for modified tracked files (unstaged)
    if ! git diff --quiet 2>/dev/null; then
        uncommitted_changes=true
    fi
    # Check for staged files
    if ! git diff --cached --quiet 2>/dev/null; then
        uncommitted_changes=true
    fi
    # Check for untracked files (excluding ignored files and .tdd-session.json)
    untracked_files=$(git ls-files --others --exclude-standard 2>/dev/null | grep -v '^\.tdd-session\.json$' || true)
    if [ -n "$untracked_files" ]; then
        uncommitted_changes=true
    fi
fi

# Validate based on phase and state
case "$phase" in
    red)
        if [ "$uncommitted_changes" = true ]; then
            block_stop "Incomplete RED phase cycle" "🔴 TDD Session Incomplete: You are in RED phase with uncommitted changes.

Kata: $kata_name
Phase: RED (failing test)

You should:
1. Commit your failing test, OR
2. Move to GREEN phase by implementing the solution, OR
3. Discard changes if abandoning this test

Stopping now would lose your work. Complete the cycle or save your progress first.

Commands:
- /kata-status - Check current session status
- git add . && git commit -m \"...\" - Commit your changes
- /complete-kata - Mark kata as complete if done"
        else
            # In RED phase but no uncommitted changes - probably just committed the failing test
            # This is a valid stopping point
            approve_stop "💡 Tip: You're in RED phase (failing test). When you return, implement the solution to make it pass (GREEN phase)."
        fi
        ;;
    green)
        if [ "$uncommitted_changes" = true ]; then
            block_stop "Incomplete GREEN phase cycle" "🟢 TDD Session Incomplete: You are in GREEN phase with uncommitted changes.

Kata: $kata_name
Phase: GREEN (make it pass)

You should:
1. Ensure all tests pass, OR
2. Commit your passing implementation, OR
3. Move to REFACTOR phase

Stopping now would lose your work. Complete the cycle or save your progress first.

Commands:
- Run your tests to verify they pass
- git add . && git commit -m \"...\" - Commit passing implementation
- /kata-status - Update to REFACTOR phase if tests pass"
        else
            # In GREEN phase with no uncommitted changes - probably just committed passing code
            # This is a valid stopping point
            approve_stop "💡 Tip: You're in GREEN phase (tests passing). When you return, consider refactoring to improve code quality."
        fi
        ;;
    refactor)
        if [ "$uncommitted_changes" = true ]; then
            block_stop "Incomplete REFACTOR phase cycle" "🔵 TDD Session Incomplete: You are in REFACTOR phase with uncommitted changes.

Kata: $kata_name
Phase: REFACTOR (improve code)

You should:
1. Ensure all tests still pass after refactoring, OR
2. Commit your refactored code, OR
3. Discard changes if refactoring didn't work out

Stopping now would lose your work. Complete the cycle or save your progress first.

Commands:
- Run your tests to verify they still pass
- git add . && git commit -m \"...\" - Commit refactored code
- /kata-status - Move to RED phase for next test if done refactoring"
        else
            # In REFACTOR phase with no uncommitted changes - probably just committed refactored code
            # This is a valid stopping point
            approve_stop "💡 Tip: You're in REFACTOR phase (code quality). When you return, start the next RED-GREEN-REFACTOR cycle with a new test."
        fi
        ;;
    awaiting_decision)
        # In AWAITING_DECISION phase - this is a valid stopping point
        # User has completed a cycle and can decide later whether to continue
        approve_stop "🤔 You're at a decision point after completing a TDD cycle.

When you return:
- Run /kata-status to decide whether to continue or complete the kata"
        ;;
    complete)
        # Kata is complete, always allow stopping
        approve_stop "✅ Kata '$kata_name' is complete. Great work on practicing TDD!"
        ;;
    *)
        # Unknown phase - allow but warn
        approve_stop "⚠️ Warning: TDD session has unknown phase '$phase'. Allowing stop but consider running /kata-status to check your session."
        ;;
esac

# Default: approve
approve_stop ""
