---
name: kata-status
description: Display current TDD kata session status including phase, TODO list, recent commits, and lessons learned. If phase is awaiting_decision, prompts user and resumes workflow.
argument-hint: ""
allowed-tools: ["Read", "Bash", "Write", "AskUserQuestion", "Task"]
---

# Kata Status Command

Display comprehensive status of the current TDD kata session.

## Execution Steps

### 1. Check for Active Session

Read `.tdd-session.json` to verify an active session exists.

**If file doesn't exist**:
- Display: "No active kata session. Start one with /start-kata"
- Exit

### 2. Read Session State

Parse `.tdd-session.json`:
```json
{
  "phase": "red|green|refactor|awaiting_decision|complete",
  "language": "...",
  "toolchain": {...},
  "constraints": [...],
  "workspaceDir": "...",
  "createdAt": "...",
  "lastUpdated": "..."
}
```

### 3. Read TODO List

Read `TODO.md` to get:
- Current tasks
- Completed tasks
- Lessons learned

### 4. Get Recent Commits

Run git log to show recent TDD cycle commits:
```bash
git log --oneline --decorate -10
```

Parse commits to identify phases (test:, feat:, refactor:).

### 5. Get Test Status

Run the test framework to show current test state:

**Based on toolchain.testFramework**:
- Rust: `cargo test`
- Jest: `npm test`
- Pytest: `pytest`
- JUnit: `gradle test`
- Go: `go test`

Capture:
- Number of passing tests
- Number of failing tests
- Test output summary

### 6. Display Comprehensive Status

Format and display all information:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 TDD KATA SESSION STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 Current Phase: [RED|GREEN|REFACTOR|COMPLETE]

🔧 Environment:
  Language: [language]
  Test Framework: [framework]
  Workspace: [directory]

📋 TODO List:
  Current Tasks:
    - [ ] [current task 1]
    - [ ] [current task 2]

  Completed: [X] tasks
    - [x] [completed task 1]
    - [x] [completed task 2]

✅ Test Status:
  Passing: [N] tests
  Failing: [M] tests
  Status: [ALL PASS|FAILURES|NO TESTS]

📝 Recent Commits (last 10):
  [hash] test: [message]     ← RED phase
  [hash] feat: [message]     ← GREEN phase
  [hash] refactor: [message] ← REFACTOR phase
  ...

🎓 Lessons Learned (most recent):
  - [lesson 1]
  - [lesson 2]
  - [lesson 3]

⚠️ Constraints:
  - [constraint 1]
  - [constraint 2]

⏱️  Session Info:
  Started: [timestamp]
  Last Updated: [timestamp]
  Duration: [calculated duration]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next Steps:
[Suggestions based on current phase]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 7. Provide Phase-Specific Guidance

**If phase is "red"**:
```
Next Steps:
  • Tester agent should write next failing test
  • Review TODO.md for planned behaviors
  • Apply kata constraints from the start
```

**If phase is "green"**:
```
Next Steps:
  • Implementer agent should write minimal code to pass test
  • Resist over-implementation
  • Keep constraints in mind
```

**If phase is "refactor"**:
```
Next Steps:
  • Refactorer agent should analyze code for improvements
  • Keep tests green throughout
  • Consider preparatory refactoring
  • Document why code is clean if no changes needed
```

**If phase is "awaiting_decision"**:
```
Next Steps:
  • You've completed a TDD cycle (RED-GREEN-REFACTOR)
  • Decide: Continue with next test, or complete kata?

  To continue:
    • User should indicate they want to continue
    • Command will update phase to 'red'
    • Tester agent will launch for next failing test

  To complete:
    • User should indicate kata is done
    • Command will update phase to 'complete'
    • Session will be marked as finished
```

After displaying status, if phase is "awaiting_decision":
1. Ask user: "Continue with next cycle or complete kata? (continue/complete)"
2. If "continue":
   - Update `.tdd-session.json` phase to 'red'
   - Launch tester agent with Task tool
3. If "complete":
   - Update `.tdd-session.json` phase to 'complete'
   - Display completion message

**If phase is "complete"**:
```
Next Steps:
  • Kata complete! Review lessons learned
  • Consider practicing with different constraints
  • Start a new kata with /start-kata
```

## Display Formatting

Use formatting for readability:
- **Bold** for section headers
- `Code blocks` for paths and technical details
- Checkboxes [x] and [ ] for tasks
- Unicode symbols for visual hierarchy (📊 🎯 🔧 ✅ 📝 🎓 ⚠️ ⏱️)
- Horizontal rules (━) for section separation

## Status Interpretation

### Phase Indicators

Display current phase with visual indicator:
- 🔴 RED: Write failing test
- 🟢 GREEN: Make test pass
- 🔵 REFACTOR: Improve structure
- 🤔 AWAITING_DECISION: Decide to continue or complete
- ✅ COMPLETE: Kata finished

### Test Status Health

Interpret test results based on phase:
- **RED phase**: Should have failing tests (healthy)
- **GREEN/REFACTOR phases**: All tests should pass (healthy)
- **Unexpected**: Flag if phase and test status don't match

Example:
```
⚠️  PHASE MISMATCH DETECTED
Current Phase: RED
Test Status: All passing

This may indicate:
  • Test doesn't actually test new behavior
  • Previous implementation over-solved
  • Need to verify test is correctly written
```

### Commit History Patterns

Analyze commit pattern for TDD discipline:
- Good: test → feat → refactor cycle
- Warning: Multiple feat commits without test
- Warning: Direct to main without test first

## Error Handling

**If .tdd-session.json is corrupted**:
- Display error message
- Show raw file content
- Suggest manual fix or restart session

**If TODO.md is missing**:
- Warning: "TODO.md not found"
- Offer to recreate
- Continue showing other status info

**If git log fails**:
- Display: "Not in git repository or git not available"
- Show other status information
- Continue execution

**If test command fails**:
- Display: "Could not run tests: [error]"
- Show test framework output
- Suggest checking toolchain setup

## Usage Examples

```bash
# Check current status
/kata-status

# Typical output shows phase, tests, todos, commits
```

## Important Notes

- **Mostly read-only**: This command displays information without modifying files, EXCEPT when phase is "awaiting_decision"
- **Resumes workflow**: When phase is "awaiting_decision", prompts user and either launches tester agent (continue) or marks kata complete
- **Always available**: Can be run at any point during kata session
- **Quick reference**: Helps user understand current state without reading multiple files
- **Agent context**: Agents can use this to understand session state

---

Use this command frequently to understand kata progress and verify TDD discipline is being maintained.
