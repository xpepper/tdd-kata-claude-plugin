#!/bin/bash
# Test suite for tdd-pretool-bash-validator.sh hook script
# Run with: bash hooks/tests/test-tdd-pretool-bash-validator.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SCRIPT="$SCRIPT_DIR/../tdd-pretool-bash-validator.sh"
TEST_DIR="/tmp/tdd-kata-pretool-test-$$"

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
    run_test "Empty input allows command" "" 0 '"permissionDecision": "allow"'
}

# Test: Empty JSON object
test_empty_json() {
    run_test "Empty JSON object allows command" "{}" 0 '"permissionDecision": "allow"'
}

# Test: No session file - allow all commands
test_no_session_allow_commit() {
    run_test "No session: git commit allowed" \
        '{"cwd": "/tmp/nonexistent", "tool_input": {"command": "git commit -m \"test\""}}' \
        0 '"permissionDecision": "allow"'
}

test_no_session_allow_run() {
    run_test "No session: cargo run allowed" \
        '{"cwd": "/tmp/nonexistent", "tool_input": {"command": "cargo run"}}' \
        0 '"permissionDecision": "allow"'
}

# Test: Test commands always allowed
test_test_commands_allowed() {
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "red", "kata": {"name": "Test"}}
EOF

    run_test "cargo test allowed" \
        "{\"cwd\": \"$TEST_DIR\", \"tool_input\": {\"command\": \"cargo test\"}}" \
        0 '"permissionDecision": "allow"'

    run_test "npm test allowed" \
        "{\"cwd\": \"$TEST_DIR\", \"tool_input\": {\"command\": \"npm test\"}}" \
        0 '"permissionDecision": "allow"'

    run_test "pytest allowed" \
        "{\"cwd\": \"$TEST_DIR\", \"tool_input\": {\"command\": \"pytest\"}}" \
        0 '"permissionDecision": "allow"'

    run_test "go test allowed" \
        "{\"cwd\": \"$TEST_DIR\", \"tool_input\": {\"command\": \"go test ./...\"}}" \
        0 '"permissionDecision": "allow"'
}

# Test: RED phase - git commit blocked
test_red_phase_commit_blocked() {
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "red", "kata": {"name": "FizzBuzz"}}
EOF

    run_test "RED phase: git commit blocked" \
        "{\"cwd\": \"$TEST_DIR\", \"tool_input\": {\"command\": \"git commit -m 'test'\"}}" \
        2 "TDD Violation.*RED phase"
}

test_red_phase_git_ci_blocked() {
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "red", "kata": {"name": "FizzBuzz"}}
EOF

    run_test "RED phase: git ci blocked" \
        "{\"cwd\": \"$TEST_DIR\", \"tool_input\": {\"command\": \"git ci -m 'test'\"}}" \
        2 "TDD Violation.*RED phase"
}

# Test: GREEN phase - git commit blocked
test_green_phase_commit_blocked() {
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "green", "kata": {"name": "FizzBuzz"}}
EOF

    run_test "GREEN phase: git commit blocked" \
        "{\"cwd\": \"$TEST_DIR\", \"tool_input\": {\"command\": \"git commit -m 'implementation'\"}}" \
        2 "TDD Violation.*GREEN phase"
}

# Test: REFACTOR phase - git commit blocked
test_refactor_phase_commit_blocked() {
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "refactor", "kata": {"name": "FizzBuzz"}}
EOF

    run_test "REFACTOR phase: git commit blocked" \
        "{\"cwd\": \"$TEST_DIR\", \"tool_input\": {\"command\": \"git commit -m 'refactor'\"}}" \
        2 "TDD Violation.*REFACTOR phase"
}

# Test: RED phase - build command gets warning
test_red_phase_build_warning() {
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "red", "kata": {"name": "FizzBuzz"}}
EOF

    run_test "RED phase: cargo run warns" \
        "{\"cwd\": \"$TEST_DIR\", \"tool_input\": {\"command\": \"cargo run\"}}" \
        0 "RED phase.*failing test"
}

# Test: Malformed session file - graceful handling
test_malformed_session_file() {
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{ this is not valid json }
EOF

    local output
    local exit_code
    output=$(echo "{\"cwd\": \"$TEST_DIR\", \"tool_input\": {\"command\": \"ls\"}}" | bash "$HOOK_SCRIPT" 2>&1) && exit_code=$? || exit_code=$?

    if [ "$exit_code" -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Malformed session file handled gracefully"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} Malformed session file causes script failure (exit code: $exit_code)"
        echo "  Output: $output"
        ((FAILED++))
    fi
}

# Test: Unknown phase - allow with warning
test_unknown_phase() {
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "unknown_phase", "kata": {"name": "FizzBuzz"}}
EOF

    run_test "Unknown phase: commit allowed with warning" \
        "{\"cwd\": \"$TEST_DIR\", \"tool_input\": {\"command\": \"git commit -m 'test'\"}}" \
        0 "unknown phase"
}

# Test: Case insensitive command matching
test_case_insensitive() {
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{"phase": "red", "kata": {"name": "Test"}}
EOF

    run_test "NPM TEST (uppercase) allowed" \
        "{\"cwd\": \"$TEST_DIR\", \"tool_input\": {\"command\": \"NPM TEST\"}}" \
        0 '"permissionDecision": "allow"'

    run_test "Git Commit (mixed case) blocked" \
        "{\"cwd\": \"$TEST_DIR\", \"tool_input\": {\"command\": \"Git Commit -m 'test'\"}}" \
        2 "TDD Violation"
}

# Main test runner
main() {
    echo "========================================="
    echo "Testing tdd-pretool-bash-validator.sh"
    echo "========================================="
    echo ""

    setup

    echo "Prerequisites:"
    test_jq_available
    echo ""

    echo "Input handling tests:"
    test_empty_input
    test_empty_json
    test_malformed_session_file
    echo ""

    echo "No session tests:"
    test_no_session_allow_commit
    test_no_session_allow_run
    echo ""

    echo "Test command tests:"
    test_test_commands_allowed
    echo ""

    echo "Phase validation tests:"
    test_red_phase_commit_blocked
    test_red_phase_git_ci_blocked
    test_green_phase_commit_blocked
    test_refactor_phase_commit_blocked
    test_red_phase_build_warning
    test_unknown_phase
    echo ""

    echo "Edge case tests:"
    test_case_insensitive
    echo ""

    cleanup

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
