# TDD Kata Plugin

Practice Test-Driven Development through code katas with strict Red-Green-Refactor cycle enforcement.

## Overview

This plugin helps you practice TDD by guiding you through kata exercises with three specialized agents that enforce proper TDD discipline:

- **Tester Agent (RED)**: Writes failing tests for the next behavior
- **Implementer Agent (GREEN)**: Writes minimal code to pass the test
- **Refactorer Agent (REFACTOR)**: Improves code structure while keeping tests green

## Features

- ✅ Automatic handoff between TDD cycle phases
- ✅ Strict enforcement: tests must fail before implementation, pass before refactoring
- ✅ Shared TODO list with lessons learned across all agents
- ✅ Language-agnostic support with automated toolchain setup
- ✅ Kata constraint support (object calisthenics patterns)
- ✅ Session persistence for resuming kata practice
- ✅ Conventional commit messages for each phase

## Installation

### From Local Directory

```bash
# Run Claude Code with this plugin enabled
cc --plugin-dir /Users/pietrodibello/Documents/workspace/kata/claude-tdd-plugin/tdd-kata
```

### Global Installation

```bash
# Copy to your Claude plugins directory
cp -r tdd-kata ~/.claude/plugins/
```

## Usage

### Starting a Kata

Start a new kata session with a description file:

```bash
/start-kata path/to/kata-description.md
```

Or provide the description interactively:

```bash
/start-kata
```

The plugin will:
1. Parse kata description and constraints
2. Ask clarifying questions
3. Detect or ask for programming language
4. Set up toolchain and test framework
5. Initialize git repository
6. Automatically launch the Tester agent to begin RED phase

### Kata Description Format

Create a markdown file describing your kata:

```markdown
# Kata Name

## Description
[What the program should do]

## Constraints (optional)
- One level of indentation per method
- Don't use the ELSE keyword
- Wrap all primitives and Strings
- First class collections

## Examples
[Input/output examples]
```

### Workflow

Once started, the plugin automatically cycles through TDD phases:

1. **RED Phase** (Tester Agent):
   - Writes next failing test
   - Verifies test fails
   - Updates TODO list and lessons learned
   - Commits with `test: ...`
   - Launches Implementer Agent

2. **GREEN Phase** (Implementer Agent):
   - Writes minimal code to pass test
   - Verifies test passes
   - Updates TODO list and lessons learned
   - Commits with `feat: ...`
   - Launches Refactorer Agent

3. **REFACTOR Phase** (Refactorer Agent):
   - Analyzes code for improvements
   - Refactors while keeping tests green
   - Updates TODO list and lessons learned
   - Commits with `refactor: ...` (if changes made)
   - Asks: Continue or complete kata?

### Additional Commands

Check current kata status:

```bash
/kata-status
```

Add a constraint mid-session:

```bash
/kata-add-constraint "No primitives as method arguments"
```

## Configuration (Optional)

Create `.claude/tdd-kata.local.md` in your project:

```yaml
---
defaultLanguage: rust
defaultTestFramework: cargo test
workspaceBaseDir: ~/katas
commitMessageTemplate: "{type}: {description}"
---

# TDD Kata Plugin Settings

Optional user preferences for kata sessions.
```

## Session Files

The plugin creates two files in your kata workspace:

- **`.tdd-session.json`**: Session state (phase, language, toolchain, constraints)
- **`TODO.md`**: Shared task list with current work, completed tasks, and lessons learned

These files persist across Claude Code sessions, allowing you to resume kata practice.

## Supported Languages

Language-agnostic design supports any language with a test framework. Automated setup includes:

- **Rust**: cargo + cargo test
- **Java**: gradle/maven + JUnit
- **TypeScript/JavaScript**: npm + Jest
- **Python**: pip + pytest
- **Go**: go test
- And more...

## Hooks

The plugin enforces TDD discipline through hooks:

- **Block production code execution**: Prevents running code without tests
- **Verify test failure**: Ensures tests fail in RED phase before proceeding
- **Verify test success**: Ensures tests pass in GREEN/REFACTOR before proceeding
- **Session resume**: Automatically detects and resumes existing kata sessions

## Example Session

```
User: /start-kata fizzbuzz.md

Plugin: Reading kata description...
        Language preference? (detected: typescript)

User: typescript

Plugin: Setting up Node.js + Jest...
        Initializing git repository...
        Ready to begin! Launching Tester agent...

[Tester Agent writes first test, verifies it fails, commits]
[Implementer Agent writes minimal code, verifies it passes, commits]
[Refactorer Agent analyzes, improves structure, commits]

Plugin: Kata complete or continue with next behavior?

User: continue

[Cycle repeats...]
```

## Lessons Learned Section

Each agent contributes insights to the shared TODO.md lessons learned section:

- Over-implementation discoveries
- Refactoring that simplified next changes
- Constraint application insights
- Mistakes and how they were corrected

## License

MIT

## Contributing

Contributions welcome! Please follow TDD practices when contributing to this plugin. 😊
