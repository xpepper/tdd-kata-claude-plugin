---
name: start-kata
description: Initialize a new TDD kata session with language setup, git initialization, and automatic handoff to tester agent
argument-hint: "[optional-kata-file-path]"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "AskUserQuestion", "Task"]
---

# Start Kata Command

Initialize a new TDD kata practice session with complete environment setup and automatic agent handoff.

## Execution Steps

### 1. Get Kata Description

**If user provided file path argument**:
- Read the kata description file using Read tool
- Parse content for:
  - Kata name/description
  - Constraints (object calisthenics patterns)
  - Requirements and examples

**If no file path provided**:
- Use AskUserQuestion to ask user to describe the kata
- Ask: "Please describe the kata you want to practice" with options for common katas or custom description
- Capture kata description, constraints, and requirements

### 2. Parse Constraints

Extract kata constraints from description. Look for:
- "One level of indentation per method"
- "Don't use the ELSE keyword"
- "Wrap all primitives and Strings"
- "First class collections"
- "No getters/setters/properties"
- Other object calisthenics rules

Store constraints in a list for session state.

### 3. Clarify Requirements

Use AskUserQuestion for any ambiguities in kata description:
- Unclear requirements
- Missing examples
- Vague constraints

Get user confirmation before proceeding.

### 4. Detect or Select Language

**Auto-detect** if possible:
- Check for existing project files (Cargo.toml, package.json, pom.xml, etc.)
- If detected, confirm with user: "Detected [language] project. Use this language?"

**Ask user** if not detected:
- Use AskUserQuestion with common language options:
  - Rust
  - TypeScript/JavaScript
  - Python
  - Java
  - Go
  - Other (custom input)

### 5. Setup Toolchain

Based on selected language, perform automated setup:

**Rust**:
```bash
# Check if cargo exists
cargo --version || echo "Install Rust from https://rustup.rs"

# Initialize if needed
[ -f Cargo.toml ] || cargo init
```

**TypeScript/JavaScript**:
```bash
# Check if node exists
node --version || echo "Install Node.js"

# Initialize if needed
[ -f package.json ] || npm init -y

# Install Jest
npm list jest || npm install --save-dev jest @types/jest ts-jest typescript

# Setup Jest config if needed
[ -f jest.config.js ] || npx ts-jest config:init
```

**Python**:
```bash
# Check Python version
python3 --version || python --version

# Install pytest
pip3 install pytest || pip install pytest

# Create basic structure
mkdir -p tests
```

**Java**:
```bash
# Check Java version
java -version

# Initialize Gradle if needed
[ -f build.gradle ] || gradle init --type java-library
```

**Go**:
```bash
# Check Go version
go version

# Initialize module if needed
[ -f go.mod ] || go mod init kata
```

Document toolchain in session state.

### 6. Initialize Git Repository

```bash
# Initialize git if not already a repo
if [ ! -d .git ]; then
    git init
    git add .
    git commit -m "chore: initialize kata project with [language]"
fi
```

### 7. Create Session State Files

**Create `.tdd-session.json`**:
```json
{
  "phase": "red",
  "language": "[detected-language]",
  "toolchain": {
    "testFramework": "[cargo test|jest|pytest|junit|go test]",
    "buildTool": "[cargo|npm|pip|gradle|go]"
  },
  "constraints": [
    "constraint 1",
    "constraint 2"
  ],
  "workspaceDir": "[current-directory]",
  "createdAt": "[ISO-timestamp]",
  "lastUpdated": "[ISO-timestamp]"
}
```

**Create `TODO.md`**:
```markdown
# TODO - [Kata Name]

## Current Task
- [ ] Write first test for simplest behavior

## Completed Tasks
_None yet_

## Lessons Learned
_Session started [timestamp]_
```

### 8. Display Summary

Show user what was configured:
```
✅ Kata Session Initialized

Kata: [name]
Language: [language]
Test Framework: [framework]
Constraints:
  - [constraint 1]
  - [constraint 2]

Session files created:
  - .tdd-session.json (session state)
  - TODO.md (shared task list)

Ready to begin TDD cycle!
```

### 9. Get User Approval

Ask user: "Setup complete. Ready to launch Tester agent to begin RED phase?"

Wait for confirmation.

### 10. Launch Tester Agent

Use Task tool to automatically launch the tester agent:

```
Task tool with:
- subagent_type: "tdd-kata:tester"
- description: "Write first failing test"
- prompt: "Begin RED phase for [kata name]. Review session state and TODO.md, then write the first test for the simplest behavior."
```

## Important Notes

- **Never skip steps**: Every step provides critical setup for the TDD workflow
- **Validate toolchain**: Ensure test framework can actually run before proceeding
- **Constraints from start**: Make constraints clear so first test follows them
- **Automatic handoff**: Must launch tester agent automatically, don't wait for user
- **Reference skill**: The tdd-kata-workflow skill provides TDD guidance

## Error Handling

**If toolchain installation fails**:
- Provide clear installation instructions
- Ask user to install manually
- Wait for confirmation before proceeding

**If kata description is unclear**:
- Don't guess requirements
- Use AskUserQuestion to clarify
- Get explicit user confirmation

**If git init fails**:
- Check if already in a git repo
- Ask user if they want to initialize anyway
- Proceed based on user preference

## Usage Examples

```bash
# With kata file
/start-kata katas/fizzbuzz.md

# Interactive mode
/start-kata
> Please describe your kata...

# From current directory (auto-detect language)
/start-kata
> Detected package.json, use TypeScript?
```

---

Follow these steps to set up a complete TDD kata environment and smoothly transition to the first RED phase.
