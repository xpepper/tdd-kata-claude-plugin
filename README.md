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

## Prerequisites

- **Claude Code CLI** (`claude`) installed and configured
- **Git** for version control (automatically initialized by the plugin)
- **Language toolchain** for your chosen language, for example:
  - Rust: `cargo` (install from [rustup.rs](https://rustup.rs))
  - TypeScript/JavaScript: `node` and `npm`
  - Python: `python3` and `pip`
  - Java: `java` and `gradle` or `maven`
  - Go: `go` toolchain

The plugin will detect existing toolchains and guide you through installation if needed.

## Installation

### Option 1: Local Usage (Temporary)

Use the plugin for a specific session without installing it globally:

```bash
# Clone the repository
git clone https://github.com/xpepper/tdd-kata-claude-plugin.git

# Run Claude Code with the plugin
claude --plugin-dir ./tdd-kata-claude-plugin
```

This works from any directory by pointing to the plugin location:

```bash
claude --plugin-dir /path/to/tdd-kata-claude-plugin
```

### Option 2: Global Installation (Persistent)

Install the plugin globally so it's automatically available in all sessions:

```bash
# Clone and copy to Claude plugins directory
git clone https://github.com/xpepper/tdd-kata-claude-plugin.git
mkdir -p ~/.claude/plugins
cp -r tdd-kata-claude-plugin ~/.claude/plugins/tdd-kata

# Now just run Claude normally - the plugin auto-loads
claude
```

### Verify Installation

Check that the plugin loaded successfully:

```bash
# Start Claude Code
claude

# Check available commands (should see start-kata, kata-status, etc.)
/help
```

## Quick Start

Try the plugin with the classic FizzBuzz kata:

```bash
# 1. Create a practice directory
mkdir -p ~/katas/fizzbuzz
cd ~/katas/fizzbuzz

# 2. Create a kata description file
cat > kata.md <<'EOF'
# FizzBuzz Kata

## Description
Write a program that returns:
- "Fizz" for multiples of 3
- "Buzz" for multiples of 5
- "FizzBuzz" for multiples of both
- The number as a string otherwise

## Examples
- Input: 1 → Output: "1"
- Input: 3 → Output: "Fizz"
- Input: 5 → Output: "Buzz"
- Input: 15 → Output: "FizzBuzz"

## Constraints
- One level of indentation per method
- Don't use the ELSE keyword
EOF

# 3. Start Claude Code with the plugin
# Local usage (Option 1):
claude --plugin-dir /path/to/tdd-kata-claude-plugin

# Global installation (Option 2):
claude

# 4. In Claude Code, run:
/start-kata kata.md

# 5. Follow the agent guidance through RED-GREEN-REFACTOR cycles!
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

## Troubleshooting

### Plugin not loading?

```bash
# Verify plugin directory structure
ls -la /path/to/tdd-kata-claude-plugin/

# Should see plugin.json file

# Run with debug mode (local usage)
claude --debug --plugin-dir /path/to/tdd-kata-claude-plugin

# Or for global installation
claude --debug
```

### Commands not appearing in /help?

- Restart Claude Code after installing the plugin
- For local usage: Check that the `--plugin-dir` path is correct
- For global installation: Verify the plugin is in `~/.claude/plugins/tdd-kata/`
- Ensure `plugin.json` exists in the plugin directory

### Hooks not working?

- Hooks load at session start - restart Claude Code after any hook changes
- Use `claude --debug` to see hook execution logs
- Check `hooks/hooks.json` for JSON syntax errors

### Session not resuming?

- Check for `.tdd-session.json` file in your kata directory
- Verify the file contains valid JSON
- SessionStart hook should detect and display session info on startup

## Additional Resources

- **Object Calisthenics Reference**: See `skills/tdd-kata-workflow/references/object-calisthenics.md`
- **TDD Cycle Guide**: See `skills/tdd-kata-workflow/references/tdd-cycle-guide.md`

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! To contribute:

1. **Practice TDD**: Follow the RED-GREEN-REFACTOR cycle when contributing
2. **Test your changes**: Use the plugin itself to develop new features
3. **Document**: Update README and relevant documentation
4. **Follow conventions**: Use conventional commits and plugin best practices

Please open an issue first to discuss significant changes.

## Support

If you encounter issues or have questions:

1. Check the [Troubleshooting](#troubleshooting) section above
2. Review the plugin documentation in the `skills/` directory
3. Open an issue on GitHub (if repository is available)

## Acknowledgments

Built with Claude Code plugin development best practices and inspired by the TDD community's commitment to disciplined software craftsmanship.
