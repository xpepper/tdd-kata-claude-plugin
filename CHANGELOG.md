# Changelog

All notable changes to the TDD Kata Claude Plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[0.1.2]: https://github.com/xpepper/tdd-kata-claude-plugin/releases/tag/v0.1.2
[0.1.1]: https://github.com/xpepper/tdd-kata-claude-plugin/releases/tag/v0.1.1
[0.1.0]: https://github.com/xpepper/tdd-kata-claude-plugin/releases/tag/v0.1.0
