# Changelog

All notable changes to the TDD Kata Claude Plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-01-19

### Fixed
- Add support for `awaiting_decision` phase throughout plugin
  - Kata now properly pauses after each REFACTOR cycle for user to decide whether to continue or complete
  - `/kata-status` now detects `awaiting_decision` phase and offers to continue or complete
  - Hook validators now recognize `awaiting_decision` as valid phase
  - Added test coverage for `awaiting_decision` in both PreToolUse and Stop hooks (45 total tests, was 43)

### Added
- TDD Testing Ground Rules documentation
  - Comprehensive guidelines for both agents and humans
  - Covers test independence, minimal implementation, refactoring discipline, and more
  - Referenced in tester agent instructions and README
- BACKLOG.md for tracking improvement ideas
  - Structured backlog with priority levels (🔴 High, 🟡 Medium, 🟢 Low)
  - Categories: Features, Enhancements, Bug Fixes, Documentation, Technical Debt
  - Six initial items captured:
    - **YOLO Mode**: Continuous TDD flow without user intervention
    - **Kata Description Persistence**: Store and reference full kata description in session
    - **Kata Library Integration**: Browse and start katas from built-in library
    - **TDD Style Selector**: Choose Classic/Chicago/Outside-In/TPP approaches
    - **Constraint Library & Presets**: Predefined constraint sets beyond Object Calisthenics
    - **Multi-Paradigm Support**: Better functional programming and paradigm-specific guidance

### Changed
- Enhanced all agent documentation with clearer responsibilities and processes:
  - **Tester agent**: Emphasized learning opportunities in RED phase, refined TDD principles
  - **Implementer agent**: Streamlined guidelines for minimal implementation focus
  - **Refactorer agent**: Improved clarity on process adherence and kata requirements
- Added kata description/requirements to session context files
- Clarified how kata constraints impact implementation choices
- Updated priority levels for several backlog items based on strategic importance

## [0.2.0] - 2026-01-18

### Changed
- **BREAKING INTERNAL**: Migrate hooks from prompt-based to command-based implementation
  - PreToolUse hook now uses bash script for deterministic validation (10s timeout vs 45s)
  - Stop hook now uses bash script for reliable cycle completion checking
  - Improved performance: 4.5x faster hook execution
  - Improved reliability: deterministic file I/O instead of LLM reasoning
  - Backward compatible: no user-facing changes required

### Added
- Comprehensive test suites for all hook scripts (43 total tests)
  - `test-tdd-pretool-bash-validator.sh` (18 tests)
  - `test-tdd-stop-validator.sh` (16 tests)
  - `test-session-start.sh` (9 tests - from previous release)
- Code smell detection reference catalogues for refactorer agent
  - Compact reference: `code_smells_agents.md` with detection protocol
  - Extended catalogue: `code-smells-expanded.md` for ambiguous cases
- Development section in README with shell script testing guide
- Hook testing documentation in `.github/copilot-instructions.md`
- Git command best practices documentation (`--no-pager` usage)

### Documentation
- Reference code smell catalogues in refactorer agent instructions
- Reorganize README "Additional Resources" with subsections
- Add step-by-step testing procedures for contributors
- Update contributing guidelines with testing requirements

## [0.1.2] - 2026-01-18

### Fixed
- Fix plugin validation: `repository` field must be a string URL, not an object
- Fix session-start.sh hook: add robust error handling to prevent plugin loading failures
  - Handle invalid JSON input gracefully
  - Handle corrupted `.tdd-session.json` files
  - Remove `set -e` that was causing silent failures

### Added
- Test suite for session-start.sh hook (`hooks/tests/test-session-start.sh`)
- Plugin development documentation in `.github/copilot-instructions.md`

### Changed
- Re-enable SessionStart hook now that error handling is robust

## [0.1.1] - 2026-01-18

### Fixed
- Remove incorrect email from author information in plugin metadata
- Update installation instructions for clarity and consistency
- Remove redundant installation option from README

### Changed
- Simplify installation guide to two clear options: local usage and global installation
- Update release workflow to match new README structure

## [0.1.0] - 2026-01-18

### Added
- Initial release of TDD Kata Claude Plugin
- Three specialized agents for TDD cycle:
  - Tester agent (RED phase) - Writes failing tests
  - Implementer agent (GREEN phase) - Writes minimal code to pass tests
  - Refactorer agent (REFACTOR phase) - Improves code structure
- Automatic agent handoff through RED-GREEN-REFACTOR cycle
- Three commands:
  - `/start-kata` - Initialize kata session with language setup
  - `/kata-status` - Display comprehensive session status
  - `/kata-add-constraint` - Add constraints mid-session
- TDD workflow skill with comprehensive guidance
  - Object calisthenics reference (9 rules)
  - TDD cycle deep dive guide
- Hooks for TDD discipline enforcement:
  - Block running production code without tests
  - Verify test fails in RED phase before commit
  - Verify tests pass in GREEN/REFACTOR before commit
  - Detect and resume existing sessions on startup
  - Validate cycle completion before stopping
- Language-agnostic support:
  - Rust (cargo + cargo test)
  - TypeScript/JavaScript (npm + Jest)
  - Python (pip + pytest)
  - Java (gradle/maven + JUnit)
  - Go (go test)
- Session persistence via `.tdd-session.json`
- Shared TODO list with lessons learned
- Conventional commit messages for each phase
- Complete documentation and troubleshooting guide

### Features
- Prompt-based hooks for intelligent validation
- Automatic toolchain detection and setup
- Kata constraint support (object calisthenics)
- Session resume capability
- Git integration with automatic commits

[0.3.0]: https://github.com/xpepper/tdd-kata-claude-plugin/releases/tag/v0.3.0
[0.2.0]: https://github.com/xpepper/tdd-kata-claude-plugin/releases/tag/v0.2.0
[0.1.2]: https://github.com/xpepper/tdd-kata-claude-plugin/releases/tag/v0.1.2
[0.1.1]: https://github.com/xpepper/tdd-kata-claude-plugin/releases/tag/v0.1.1
[0.1.0]: https://github.com/xpepper/tdd-kata-claude-plugin/releases/tag/v0.1.0
