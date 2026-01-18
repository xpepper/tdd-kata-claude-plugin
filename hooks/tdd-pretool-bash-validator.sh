#!/bin/bash
# PreToolUse hook for TDD discipline enforcement
# Validates Bash commands against TDD Red-Green-Refactor cycle rules

set -euo pipefail

# Helper function to allow with message
allow_with_message() {
    local message="${1:-}"
    jq -n --arg msg "$message" '{
        "hookSpecificOutput": {
            "permissionDecision": "allow",
            "updatedInput": null
        },
        "systemMessage": $msg
    }'
    exit 0
}

# Helper function to deny with reason
deny_with_reason() {
    local reason="$1"
    jq -n --arg reason "$reason" '{
        "hookSpecificOutput": {
            "permissionDecision": "deny",
            "updatedInput": null
        },
        "systemMessage": $reason
    }' >&2
    exit 2
}

# Read input from stdin
input=$(cat)

# Extract working directory and command
cwd=$(echo "$input" | jq -r '.cwd // ""')
command=$(echo "$input" | jq -r '.tool_input.command // ""')

if [ -z "$cwd" ] || [ -z "$command" ]; then
    allow_with_message ""
fi

# Check if TDD session exists
session_file="$cwd/.tdd-session.json"

if [ ! -f "$session_file" ]; then
    # No active TDD session, allow everything
    allow_with_message ""
fi

# Validate session file is valid JSON
if ! jq empty "$session_file" 2>/dev/null; then
    allow_with_message "⚠️ Warning: .tdd-session.json is corrupted. Allowing command but consider running /kata-status"
fi

# Read current phase from session
phase=$(jq -r '.phase // "unknown"' "$session_file" 2>/dev/null)

# Normalize command for analysis (lowercase, trim whitespace)
cmd_lower=$(echo "$command" | tr '[:upper:]' '[:lower:]' | xargs)

# Check if this is a test command (allow all test commands)
if echo "$cmd_lower" | grep -qE '(cargo test|npm test|npm run test|yarn test|pytest|python -m pytest|go test|mvn test|gradle test|rspec|jest|mocha|vitest|bun test)'; then
    allow_with_message ""
fi

# Check if this is a git commit command
if echo "$cmd_lower" | grep -qE '^git\s+(commit|ci)'; then
    # Validate commit based on current phase
    case "$phase" in
        red)
            # In RED phase, commits should only happen if tests are failing
            # We can't directly check test output here, but we can warn
            deny_with_reason "🔴 TDD Violation: You are in RED phase (failing test).

Before committing, ensure:
1. You have written a FAILING test
2. The test output shows failures
3. You are committing the test itself (not implementation)

If you've written the failing test and want to commit it, your tests should be failing.

Next steps:
- Run your test command to verify tests are failing
- If tests are passing, you've moved to GREEN phase - update with /kata-status
- Commit only the failing test, not the implementation"
            ;;
        green)
            # In GREEN phase, tests should be passing before commit
            deny_with_reason "🟢 TDD Violation: You are in GREEN phase (make it pass).

Before committing, ensure:
1. All tests are PASSING
2. You've written minimal code to make the test pass
3. You are committing the implementation that makes the test pass

Next steps:
- Run your test command to verify all tests pass
- If tests are still failing, continue working on implementation
- If tests pass, commit the implementation
- After committing, move to REFACTOR phase with /kata-status"
            ;;
        refactor)
            # In REFACTOR phase, tests should remain passing
            deny_with_reason "🔵 TDD Violation: You are in REFACTOR phase (improve the code).

Before committing, ensure:
1. All tests are still PASSING
2. You've improved code quality without changing behavior
3. No new functionality was added

Next steps:
- Run your test command to verify all tests still pass
- If tests are failing, fix the refactoring
- If tests pass, commit the refactored code
- After committing, move to RED phase for next test with /kata-status"
            ;;
        *)
            # Unknown phase, allow but warn
            allow_with_message "⚠️ Warning: TDD session has unknown phase '$phase'. Allowing commit but verify your TDD cycle is correct."
            ;;
    esac
fi

# Check if this is a build/run command in RED phase
if [ "$phase" = "red" ]; then
    if echo "$cmd_lower" | grep -qE '(cargo run|npm start|npm run|node |python |go run|java -jar|gradle run)'; then
        # Exclude test commands (already handled earlier)
        if ! echo "$cmd_lower" | grep -qE '(pytest|python -m pytest)'; then
            allow_with_message "⚠️ Reminder: You are in RED phase. Make sure you have a failing test before implementing functionality."
        fi
    fi
fi

# Allow all other commands
allow_with_message ""
