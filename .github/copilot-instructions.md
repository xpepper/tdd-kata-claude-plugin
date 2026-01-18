# TDD Kata Plugin - AI Agent Instructions

This is a Claude Code plugin that enforces strict TDD discipline through specialized agents.

## Architecture Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Tester Agent   │────▶│ Implementer     │────▶│  Refactorer     │
│  (RED phase)    │     │ (GREEN phase)   │     │  (REFACTOR)     │
└────────┬────────┘     └─────────────────┘     └────────┬────────┘
         │                                               │
         └───────────────────────────────────────────────┘
                    (automatic cycle)
```

**Key components:**
- [agents/](agents/) - Three specialized TDD phase agents (tester, implementer, refactorer)
- [commands/](commands/) - Slash commands (`/start-kata`, `/kata-status`, `/kata-add-constraint`)
- [hooks/hooks.json](hooks/hooks.json) - TDD discipline enforcement hooks
- [skills/tdd-kata-workflow/](skills/tdd-kata-workflow/) - Core TDD knowledge and references

## Critical Session State Files

Agents read/write these files during kata sessions:
- **`.tdd-session.json`** - Session state: `phase` (red/green/refactor), `language`, `constraints[]`
- **`TODO.md`** - Shared task list with lessons learned across agents

## Agent Handoff Pattern

Each agent MUST:
1. Read `.tdd-session.json` to understand current phase and constraints
2. Complete its specific responsibility (write test / implement / refactor)
3. Run tests to verify expected state (fail for RED, pass for GREEN/REFACTOR)
4. Commit with conventional message: `test:`, `feat:`, or `refactor:`
5. Update `.tdd-session.json` phase and launch next agent via Task tool

## TDD Phase Responsibilities

| Phase     | Agent        | Test State   | Commit Prefix | Next Phase |
|-----------|--------------|--------------|---------------|------------|
| RED       | tester       | Must FAIL    | `test:`       | green      |
| GREEN     | implementer  | Must PASS    | `feat:`       | refactor   |
| REFACTOR  | refactorer   | Must PASS    | `refactor:`   | red (or complete) |

## Constraints & Object Calisthenics

Kata constraints are stored in `.tdd-session.json` `constraints[]`.
Let the user choose which constraints to apply, don't force any of them by default.
An example of a possible set of deliberate contraints to let you practice TDD skills out of your comfort zone are defined in [references/object-calisthenics.md](skills/tdd-kata-workflow/references/object-calisthenics.md):
- "One level of indentation per method"
- "Don't use the ELSE keyword"
- "Wrap all primitives and Strings"


## Hooks Enforcement

[hooks/hooks.json](hooks/hooks.json) enforces discipline:
- **SessionStart** - Detects and resumes existing kata sessions
- **PreToolUse (Bash)** - Blocks commits if test state doesn't match phase
- **Stop** - Prevents stopping mid-cycle (incomplete RED-GREEN-REFACTOR)

## Making Changes

When modifying agents or commands:
- Agent files use YAML frontmatter with `name`, `description`, `model`, `color`
- Commands define `allowed-tools` in frontmatter
- Test changes manually by running `/start-kata` with a sample kata

## Plugin Development & Validation

**Always validate after changes:**
```bash
claude plugin validate ~/path/to/tdd-kata
```

**Common plugin.json pitfalls:**
- `repository` must be a **string URL**, not `{"type": "git", "url": "..."}` object
- Run validation before testing - invalid manifests silently prevent plugin loading

**Testing hooks:**
- Hook scripts with `set -e` will crash on ANY error, breaking plugin load
- Test [hooks/session-start.sh](hooks/session-start.sh) with: `bash hooks/tests/test-session-start.sh`
- Hook scripts must handle: invalid JSON input, missing files, corrupted session files

**Running git commands programmatically:**
- Always use `git --no-pager` to avoid getting stuck in alternate buffer (pager like `less`)
- Example: `git --no-pager log --oneline -5` or `git --no-pager tag -l`

**Testing the plugin:**
```bash
claude --plugin-dir ~/path/to/tdd-kata --print "list slash commands"
```

## Releasing a New Version

1. **Update versions** in `.claude-plugin/plugin.json` and `marketplace.json`
2. **Update CHANGELOG.md** with new version section and link at bottom
3. **Commit**: `git commit -m "chore: bump version to X.Y.Z"`
4. **Tag**: `git tag vX.Y.Z -m "Release vX.Y.Z"`
5. **Push**: `git push origin main --tags`

The GitHub Actions workflow ([.github/workflows/release.yml](.github/workflows/release.yml)) automatically creates a release with a zip archive when a `v*` tag is pushed.

## TDD Styles
Let the user choose which TDD style to follow.

Some examples:
- **Classic TDD** - Kent Beck style: from known to unknown. Let the tests drive design and explore the problem space and the solution space.
- **Chicago School TDD** - Bob Martin ("uncle bob") style. Use mocks just to verify interactions with external dependencies, but focus on state verification within the system under test.
- **Outside-In TDD** - Start from high-level features, work down to implementation, like in London School TDD. Make use of mocks and stubs to define interactions before implementation.
- **Transformation Priority Premise** - Tests should follow the Transformation Priority Premise (defined in [tdd-cycle-guide.md](skills/tdd-kata-workflow/references/tdd-cycle-guide.md#L74-L86)):
  1. Constant → Variable → Conditional → Iteration → Recursion
  2. Pick simplest transformation that fails, not the most obvious feature
