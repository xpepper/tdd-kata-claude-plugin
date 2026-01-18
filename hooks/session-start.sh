#!/bin/bash
# Session start hook for TDD Kata plugin
# Detects existing kata sessions and displays status message

# Don't use set -e - we want to handle errors gracefully
set -uo pipefail

# Default response (silent, continue)
default_response() {
    echo '{"systemMessage": "", "continue": true}'
}

# Read input from stdin
input=$(cat)

# Validate input is valid JSON and has cwd field
cwd=$(echo "$input" | jq -r '.cwd' 2>/dev/null)
if [ -z "$cwd" ] || [ "$cwd" = "null" ]; then
    # Invalid input or missing cwd - exit silently
    default_response
    exit 0
fi

# Check if .tdd-session.json exists
session_file="$cwd/.tdd-session.json"

if [ ! -f "$session_file" ]; then
  # No session found, return empty (silent)
  default_response
  exit 0
fi

# Validate session file is valid JSON
if ! jq empty "$session_file" 2>/dev/null; then
    # Session file is corrupted - warn but don't fail
    jq -n '{
      "systemMessage": "⚠️ Warning: .tdd-session.json is corrupted. Consider deleting it and starting fresh with /start-kata",
      "continue": true
    }'
    exit 0
fi

# Read session data with error handling
phase=$(jq -r '.phase // "unknown"' "$session_file" 2>/dev/null || echo "unknown")
language=$(jq -r '.language // "unknown"' "$session_file" 2>/dev/null || echo "unknown")
kata_name=$(jq -r '.kata.name // "Unknown Kata"' "$session_file" 2>/dev/null || echo "Unknown Kata")
iteration=$(jq -r '.kata.iteration // ""' "$session_file" 2>/dev/null || echo "")
last_updated=$(jq -r '.lastUpdated // ""' "$session_file" 2>/dev/null || echo "")

# Build iteration string
iteration_str=""
if [ -n "$iteration" ] && [ "$iteration" != "null" ]; then
  iteration_str=" (Iteration $iteration)"
fi

# Build last updated string
updated_str=""
if [ -n "$last_updated" ] && [ "$last_updated" != "null" ]; then
  updated_str="
Last updated: $last_updated"
fi

# Read constraints (first 3)
constraints=$(jq -r '.constraints[0:3] | join("\n  • ")' "$session_file" 2>/dev/null || echo "")
constraints_str=""
if [ -n "$constraints" ] && [ "$constraints" != "null" ] && [ "$constraints" != "" ]; then
  constraints_str="

Active constraints:
  • $constraints"
fi

# Create message
message="🎯 TDD Kata Session Detected!

Kata: $kata_name$iteration_str
Phase: ${phase^^}
Language: $language$updated_str$constraints_str

💡 Use /kata-status for full session details"

# Return JSON with systemMessage
jq -n --arg msg "$message" '{
  "systemMessage": $msg,
  "continue": true
}'
