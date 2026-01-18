#!/bin/bash
# Test suite for session-start.sh hook script
# Run with: bash hooks/tests/test-session-start.sh

# Don't use set -e because we're testing for failures
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SCRIPT="$SCRIPT_DIR/../session-start.sh"
TEST_DIR="/tmp/tdd-kata-test-$$"

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
    run_test "Empty input returns success" "" 0 '"continue": true'
}

# Test: Empty JSON object
test_empty_json() {
    run_test "Empty JSON object returns success" "{}" 0 '"continue": true'
}

# Test: No session file exists
test_no_session_file() {
    run_test "No session file - silent success" '{"cwd": "/tmp/nonexistent-dir-xyz"}' 0 '"systemMessage": ""'
}

# Test: Invalid JSON input - THIS IS THE BUG!
test_invalid_json_input() {
    local output
    local exit_code
    output=$(echo "not valid json" | bash "$HOOK_SCRIPT" 2>&1) && exit_code=$? || exit_code=$?

    if [ "$exit_code" -ne 0 ]; then
        echo -e "${RED}✗${NC} Invalid JSON input causes script failure (exit code: $exit_code)"
        echo "  This is likely why the plugin fails to load!"
        echo "  Output: $output"
        ((FAILED++))
    else
        echo -e "${GREEN}✓${NC} Invalid JSON input handled gracefully"
        ((PASSED++))
    fi
}

# Test: Valid session file
test_valid_session() {
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{
  "phase": "red",
  "language": "rust",
  "kata": {
    "name": "FizzBuzz",
    "iteration": 1
  },
  "constraints": ["One level of indentation", "No ELSE keyword"],
  "lastUpdated": "2026-01-18T10:00:00Z"
}
EOF
    run_test "Valid session file detected" "{\"cwd\": \"$TEST_DIR\"}" 0 "TDD Kata Session Detected"
}

# Test: Session file with missing fields
test_partial_session() {
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{
  "phase": "green",
  "language": "python"
}
EOF
    run_test "Partial session file handled" "{\"cwd\": \"$TEST_DIR\"}" 0 '"continue": true'
}

# Test: Malformed session file - THIS IS ANOTHER BUG!
test_malformed_session_file() {
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{ this is not valid json }
EOF
    local output
    local exit_code
    output=$(echo "{\"cwd\": \"$TEST_DIR\"}" | bash "$HOOK_SCRIPT" 2>&1) && exit_code=$? || exit_code=$?

    if [ "$exit_code" -ne 0 ]; then
        echo -e "${RED}✗${NC} Malformed session file causes script failure (exit code: $exit_code)"
        echo "  Output: $output"
        ((FAILED++))
    else
        echo -e "${GREEN}✓${NC} Malformed session file handled gracefully"
        ((PASSED++))
    fi
}

# Test: Session file with empty constraints
test_empty_constraints() {
    cat > "$TEST_DIR/.tdd-session.json" << 'EOF'
{
  "phase": "refactor",
  "language": "typescript",
  "kata": {"name": "StringCalculator"},
  "constraints": []
}
EOF
    run_test "Empty constraints handled" "{\"cwd\": \"$TEST_DIR\"}" 0 "StringCalculator"
}

# Main test runner
main() {
    echo "========================================="
    echo "Testing session-start.sh hook script"
    echo "========================================="
    echo ""

    setup

    echo "Prerequisites:"
    test_jq_available
    echo ""

    echo "Input handling tests:"
    test_empty_input
    test_empty_json
    test_invalid_json_input
    echo ""

    echo "Session file tests:"
    test_no_session_file
    test_valid_session
    test_partial_session
    test_malformed_session_file
    test_empty_constraints
    echo ""

    cleanup

    echo "========================================="
    echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}"
    echo "========================================="

    if [ "$FAILED" -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}⚠️  Some tests failed!${NC}"
        echo "The script needs error handling improvements to prevent plugin loading failures."
        exit 1
    fi
}

main "$@"
