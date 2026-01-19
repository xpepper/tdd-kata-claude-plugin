#!/bin/bash
# Test suite for tdd-stop-validator.sh hook script
# Run with: bash hooks/tests/test-tdd-stop-validator.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SCRIPT="$SCRIPT_DIR/../tdd-stop-validator.sh"
TEST_DIR="/tmp/tdd-kata-stop-test-$$"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0

# Setup test directory
setup() {
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    git init --quiet
    git config user.email "test@test.com"
    git config user.name "Test User"
}

# Cleanup test directory
cleanup() {
    rm -rf "$TEST_DIR"
}

# Run a test and check result
# Usage: run_test "test name" "input" expected_exit_code "expected_output_pattern"
run_test() {
    local name="$1"
    local input="$2"
    local expected_exit="$3"
    local expected_pattern="${4:-}"

    local output
    local exit_code

    output=$(echo "$input" | bash "$HOOK_SCRIPT" 2>&1) && exit_code=$? || exit_code=$?

    local test_passed=true

    # Check exit code
    if [ "$exit_code" -ne "$expected_exit" ]; then
        test_passed=false
    fi

    # Check output pattern if provided
    if [ -n "$expected_pattern" ] && ! echo "$output" | grep -q "$expected_pattern"; then
        test_passed=false
    fi

    if [ "$test_passed" = true ]; then
        echo -e "${GREEN}✓${NC} $name"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $name"
        echo "  Expected exit code: $expected_exit, got: $exit_code"
        if [ -n "$expected_pattern" ]; then
            echo "  Expected pattern: $expected_pattern"
        fi
        echo "  Output: $output"
        ((FAILED++))
    fi
}

# Test: Check jq is available
test_jq_available() {
    if command -v jq &> /dev/null; then
        echo -e "${GREEN}✓${NC} jq is available"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} jq is NOT available - this will cause hook failures"
        ((FAILED++))
    fi
}

# Test: Empty input
test_empty_input() {
    run_test "Empty input approves stop" "" 0 '"decision": "approve"'
}

# Test: Empty JSON object
test_empty_json() {
    run_test "Empty JSON object approves stop" "{}" 0 '"decision": "approve"'
}

# Test: No session file - allow stopping
test_no_session_file() {
    run_test "No session file: approve stop" \
        '{"cwd": "/tmp/nonexistent"}' \
        0 '"decision": "approve"'
}

# Test: Malformed session file - graceful handling
test_malformed_session_file() {
    setup
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{ this is not valid json }
EOF

    local output
    local exit_code
    output=$(echo "{\"cwd\": \"$TEST_DIR\"}" | bash "$HOOK_SCRIPT" 2>&1) && exit_code=$? || exit_code=$?

    if [ "$exit_code" -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Malformed session file handled gracefully"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} Malformed session file causes script failure (exit code: $exit_code)"
        echo "  Output: $output"
        ((FAILED++))
    fi
    cleanup
}

# Test: RED phase with no changes - approve
test_red_phase_no_changes() {
    setup
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "red", "kata": {"name": "FizzBuzz"}}
EOF

    run_test "RED phase, no changes: approve with tip" \
        "{\"cwd\": \"$TEST_DIR\"}" \
        0 "RED phase.*GREEN phase"
    cleanup
}

# Test: RED phase with untracked files - block
test_red_phase_untracked_files() {
    setup
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "red", "kata": {"name": "FizzBuzz"}}
EOF
    echo "test" > "$TEST_DIR/test.txt"

    run_test "RED phase, untracked files: block stop" \
        "{\"cwd\": \"$TEST_DIR\"}" \
        2 "Incomplete RED phase cycle"
    cleanup
}

# Test: RED phase with unstaged changes - block
test_red_phase_unstaged_changes() {
    setup
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "red", "kata": {"name": "FizzBuzz"}}
EOF
    echo "test" > "$TEST_DIR/test.txt"
    git add test.txt
    git commit -m "initial" --quiet
    echo "modified" > "$TEST_DIR/test.txt"

    run_test "RED phase, unstaged changes: block stop" \
        "{\"cwd\": \"$TEST_DIR\"}" \
        2 "Incomplete RED phase cycle"
    cleanup
}

# Test: RED phase with staged changes - block
test_red_phase_staged_changes() {
    setup
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "red", "kata": {"name": "FizzBuzz"}}
EOF
    echo "test" > "$TEST_DIR/test.txt"
    git add test.txt

    run_test "RED phase, staged changes: block stop" \
        "{\"cwd\": \"$TEST_DIR\"}" \
        2 "Incomplete RED phase cycle"
    cleanup
}

# Test: GREEN phase with no changes - approve
test_green_phase_no_changes() {
    setup
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "green", "kata": {"name": "FizzBuzz"}}
EOF

    run_test "GREEN phase, no changes: approve with tip" \
        "{\"cwd\": \"$TEST_DIR\"}" \
        0 "GREEN phase.*refactoring"
    cleanup
}

# Test: GREEN phase with uncommitted changes - block
test_green_phase_uncommitted_changes() {
    setup
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "green", "kata": {"name": "FizzBuzz"}}
EOF
    echo "implementation" > "$TEST_DIR/impl.rs"

    run_test "GREEN phase, uncommitted changes: block stop" \
        "{\"cwd\": \"$TEST_DIR\"}" \
        2 "Incomplete GREEN phase cycle"
    cleanup
}

# Test: REFACTOR phase with no changes - approve
test_refactor_phase_no_changes() {
    setup
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "refactor", "kata": {"name": "FizzBuzz"}}
EOF

    run_test "REFACTOR phase, no changes: approve with tip" \
        "{\"cwd\": \"$TEST_DIR\"}" \
        0 "REFACTOR phase.*next.*cycle"
    cleanup
}

# Test: REFACTOR phase with uncommitted changes - block
test_refactor_phase_uncommitted_changes() {
    setup
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "refactor", "kata": {"name": "FizzBuzz"}}
EOF
    echo "refactored" > "$TEST_DIR/code.rs"

    run_test "REFACTOR phase, uncommitted changes: block stop" \
        "{\"cwd\": \"$TEST_DIR\"}" \
        2 "Incomplete REFACTOR phase cycle"
    cleanup
}

# Test: AWAITING_DECISION phase - approve with guidance
test_awaiting_decision_phase() {
    setup
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "awaiting_decision", "kata": {"name": "FizzBuzz"}}
EOF

    run_test "AWAITING_DECISION phase: approve with guidance" \
        "{\"cwd\": \"$TEST_DIR\"}" \
        0 "decision point.*kata-status"
    cleanup
}

# Test: COMPLETE phase - always approve
test_complete_phase() {
    setup
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "complete", "kata": {"name": "FizzBuzz"}}
EOF
    echo "leftover" > "$TEST_DIR/file.txt"

    run_test "COMPLETE phase: approve even with changes" \
        "{\"cwd\": \"$TEST_DIR\"}" \
        0 "complete.*Great work"
    cleanup
}

# Test: Unknown phase - approve with warning
test_unknown_phase() {
    setup
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "unknown_phase", "kata": {"name": "FizzBuzz"}}
EOF

    run_test "Unknown phase: approve with warning" \
        "{\"cwd\": \"$TEST_DIR\"}" \
        0 "unknown phase"
    cleanup
}

# Test: Non-git directory
test_non_git_directory() {
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "red", "kata": {"name": "FizzBuzz"}}
EOF

    run_test "Non-git directory: approve stop" \
        "{\"cwd\": \"$TEST_DIR\"}" \
        0 '"decision": "approve"'
    cleanup
}

# Main test runner
main() {
    echo "========================================="
    echo "Testing tdd-stop-validator.sh"
    echo "========================================="
    echo ""

    echo "Prerequisites:"
    test_jq_available
    echo ""

    echo "Input handling tests:"
    test_empty_input
    test_empty_json
    test_no_session_file
    test_malformed_session_file
    echo ""

    echo "RED phase tests:"
    test_red_phase_no_changes
    test_red_phase_untracked_files
    test_red_phase_unstaged_changes
    test_red_phase_staged_changes
    echo ""

    echo "GREEN phase tests:"
    test_green_phase_no_changes
    test_green_phase_uncommitted_changes
    echo ""

    echo "REFACTOR phase tests:"
    test_refactor_phase_no_changes
    test_refactor_phase_uncommitted_changes
    echo ""

    echo "Special cases:"
    test_awaiting_decision_phase
    test_complete_phase
    test_unknown_phase
    test_non_git_directory
    echo ""

    echo "========================================="
    echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}"
    echo "========================================="

    if [ "$FAILED" -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}⚠️  Some tests failed!${NC}"
        exit 1
    fi
}

main "$@"
