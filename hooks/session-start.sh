#!/bin/bash
set -euo pipefail

# Read input from stdin
input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')

# Check if .tdd-session.json exists
session_file="$cwd/.tdd-session.json"

if [ -f "$session_file" ]; then
  # Read session data
  phase=$(jq -r '.phase // "unknown"' "$session_file")
  language=$(jq -r '.language // "unknown"' "$session_file")
  kata_name=$(jq -r '.kata.name // "Unknown Kata"' "$session_file")
  iteration=$(jq -r '.kata.iteration // ""' "$session_file")
  last_updated=$(jq -r '.lastUpdated // ""' "$session_file")

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
  if [ -n "$constraints" ] && [ "$constraints" != "null" ]; then
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
else
  # No session found, return empty (silent)
  echo '{"systemMessage": "", "continue": true}'
fi
