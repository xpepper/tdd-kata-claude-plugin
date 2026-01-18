---
name: TDD Kata Workflow
description: This skill should be used when the user asks to "practice TDD", "start a kata", "code kata", "test-driven development", "red green refactor", mentions "object calisthenics" constraints, or when agents in the tdd-kata plugin need TDD cycle guidance. Provides comprehensive TDD best practices and kata workflow orchestration.
version: 0.1.0
---

# TDD Kata Workflow

## Overview

Test-Driven Development (TDD) is a software development discipline where tests drive the implementation. Code katas are practice exercises designed to build TDD muscle memory through repetition and focus on specific constraints.

This skill provides guidance for practicing TDD through kata exercises, orchestrating the Red-Green-Refactor cycle, and applying kata constraints to improve code design.

## When to Use This Skill

Apply this skill when:
- Practicing TDD through kata exercises
- Guiding users through the Red-Green-Refactor cycle
- Working with kata constraints (object calisthenics patterns)
- Coordinating between tester, implementer, and refactorer agents
- Making decisions about minimal implementation vs refactoring

## Core TDD Principles

### The Three Laws of TDD

1. **Write no production code** except to pass a failing test
2. **Write only enough test** to demonstrate a failure
3. **Write only enough production code** to pass the failing test

These laws create a rapid cycle measured in minutes, not hours. Each cycle follows the Red-Green-Refactor pattern.

### The Red-Green-Refactor Cycle

TDD operates in three distinct phases:

**RED Phase (Write a Failing Test)**
- Identify the next behavior to implement
- Write a test that specifies this behavior
- Run the test and verify it fails
- Commit: `test: add test for <behavior>`

**GREEN Phase (Make It Pass)**
- Write the minimal code to pass the failing test
- Prioritize speed over elegance
- Run the test and verify it passes
- Commit: `feat: implement <behavior>`

**REFACTOR Phase (Improve Design)**
- Clean up code while keeping tests green
- Remove duplication
- Improve names and structure
- Consider preparatory refactoring for the next change
- Run tests after each change
- Commit: `refactor: <improvement>` (if changes made)

**Critical**: Each phase has a specific purpose. Never mix phases—don't refactor while making tests pass, don't add features while refactoring.

## Working with Kata Constraints
The user may impose specific coding constraints to force specific coding patterns that improve design.
A possible example of such constraints are the so-called "object calisthenics" (`references/object-calisthenics.md`), which include:
- **One level of indentation per method** - Encourages small, focused methods
- **Don't use the ELSE keyword** - Promotes guard clauses and early returns
- **Wrap all primitives and Strings** - Creates value objects with domain meaning
- **First class collections** - Wraps collections in domain-specific classes
- **No classes with more than two instance variables** - Encourages composition
- **No getters/setters/properties** - Enforces Tell, Don't Ask principle

When applying constraints, start from the first test. They shape implementation choices and refactoring decisions throughout the kata.

## Decision Points in the TDD Cycle

### What Makes a Test "Minimal"?

A minimal test:
- Tests one new behavior, not multiple concepts
- Uses the simplest example that demonstrates the behavior
- Fails for the right reason (missing implementation, not syntax errors)
- Can be satisfied by the simplest possible production code

**Example progression** (FizzBuzz):
1. Test input 1 returns "1" (simplest case)
2. Test input 3 returns "Fizz" (first rule)
3. Test input 5 returns "Buzz" (second rule)
4. Test input 15 returns "FizzBuzz" (combination)

Each test introduces one new concept.

### What Makes Implementation "Minimal"?

Minimal implementation:
- Passes the current test
- May use obvious or even "fake" implementations initially
- Delays generalization until tests demand it
- Avoids solving problems that don't exist yet

**Anti-patterns**:
- Adding validation before a test requires it
- Creating abstractions "for future use"
- Implementing features not covered by tests
- Over-engineering the solution

**Rule of thumb**: If removing a line of production code doesn't break a test, that line shouldn't exist.

### When to Refactor vs When to Skip

**Refactor when**:
- Code contains duplication
- Names don't clearly express intent
- Methods are too long or complex
- Current structure will resist the next change
- Constraints are violated

**Skip refactoring when**:
- Code is clean and clear
- Structure easily accommodates likely next changes
- No duplication exists
- All constraints are satisfied

**Important**: Even when skipping, document the decision in TODO.md lessons learned explaining why the code is clean or what preparatory refactoring might help later.

### Handling Unexpected Test Passes

If a test passes immediately after writing it:
1. **Stop and analyze**: Why did it pass?
2. **Common causes**:
   - Over-implemented in previous GREEN phase
   - Refactoring accidentally changed behavior
   - Test doesn't actually test the new behavior
3. **Actions**:
   - Document analysis in TODO.md lessons learned
   - Fix test to actually fail, or modify implementation to not over-solve
   - Update understanding for next cycles

Never proceed with a test that should fail but doesn't. It indicates a discipline breakdown.

## Commit Conventions

Use conventional commit format with TDD phase context:

**RED Phase**:
```
test: add test for <specific behavior>
test: verify error handling for invalid input
test: ensure FizzBuzz returns "Fizz" for multiples of 3
```

**GREEN Phase**:
```
feat: implement <specific behavior>
feat: handle invalid input with error message
feat: return "Fizz" for multiples of 3
```

**REFACTOR Phase**:
```
refactor: extract validation logic to separate method
refactor: rename variables for clarity
refactor: apply guard clause pattern to eliminate else
```

**Setup/Infrastructure**:
```
chore: initialize Rust project with cargo
chore: configure Jest testing framework
```

Each commit should represent a complete phase of the cycle. Commits provide context for the next agent about what happened and why.

## Agent Coordination

The TDD kata workflow involves three specialized agents:

### Tester Agent (RED Phase)

**Responsibilities**:
- Read recent commits and TODO.md for context
- Identify next behavior to test
- Write failing test
- Verify test fails
- Update TODO.md with lessons learned
- Commit test
- Hand off to Implementer agent

**Key considerations**:
- Choose the simplest next behavior
- Write test first, don't peek at implementation
- Ensure test failure message is clear
- Document any surprises (unexpected passes, etc.)

### Implementer Agent (GREEN Phase)

**Responsibilities**:
- Read recent commits and TODO.md for context
- Write minimal code to pass the failing test
- Verify test passes
- Update TODO.md with lessons learned
- Commit implementation
- Hand off to Refactorer agent

**Key considerations**:
- Resist over-engineering
- Apply kata constraints from the start
- Don't refactor while implementing
- Document if implementation reveals complexity

### Refactorer Agent (REFACTOR Phase)

**Responsibilities**:
- Read recent commits and TODO.md for context
- Analyze code for refactoring opportunities
- Improve structure while keeping tests green
- Update TODO.md with lessons learned
- Commit refactoring (if changes made)
- Ask user: continue or complete?
- Hand off to Tester agent (if continuing)

**Key considerations**:
- Keep tests green throughout
- Consider preparatory refactoring for next change
- Document why code is clean if no changes needed
- Run tests after each refactoring step

## TODO List Management

The shared TODO.md file coordinates work across agents:

### Structure

```markdown
## Current Task
- [ ] Write test for <next behavior>

## Completed Tasks
- [x] Write test for basic input validation
- [x] Implement basic input validation
- [x] Refactor to extract validator

## Lessons Learned
- Over-implemented in cycle 2 by adding range check too early
- Guard clause pattern from "no else" constraint simplified cycle 3
- Extracting method in refactor made cycle 4 test easier to write
```

### Update Pattern

Each agent updates TODO.md:
1. **Before work**: Add current task to "Current Task"
2. **After work**:
   - Move completed task to "Completed Tasks"
   - Add insights to "Lessons Learned"
   - Add any new tasks discovered

### Lessons Learned Guidelines

Record:
- **Mistakes**: Over-implementation, wrong abstractions, constraint violations
- **Insights**: How refactoring helped, what patterns emerged, constraint benefits
- **Observations**: Why tests passed unexpectedly, what complexity revealed
- **Future guidance**: What to watch for in next cycles

**Example lessons**:
- "Implemented validation in cycle 3 but no test required it yet - removed in cycle 4 refactor"
- "'No else' constraint led to guard clause pattern which clarified logic"
- "Test passed immediately because cycle 2 over-implemented - had to remove code"

## Session State Management

The `.tdd-session.json` file tracks kata session state:

```json
{
  "phase": "red|green|refactor|complete",
  "language": "rust",
  "toolchain": {
    "testFramework": "cargo test",
    "buildTool": "cargo"
  },
  "constraints": [
    "one level of indentation per method",
    "no else keyword"
  ],
  "workspaceDir": "/path/to/kata",
  "createdAt": "2026-01-17T10:00:00Z",
  "lastUpdated": "2026-01-17T10:30:00Z"
}
```

Update state after each phase transition to coordinate agent handoff.

## Language and Toolchain Setup

When starting a kata:
1. **Detect language** from project structure or ask user
2. **Verify toolchain** exists (cargo, npm, pytest, gradle, etc.)
3. **Install if needed** using language-specific package managers
4. **Initialize test framework** following language conventions
5. **Verify setup** by running tests (should have zero tests initially)

**Language patterns**:
- **Rust**: `cargo init`, `cargo test`
- **JavaScript/TypeScript**: `npm init`, `npm install jest`, `npm test`
- **Python**: `pip install pytest`, `pytest`
- **Java**: `gradle init`, `gradle test`

Document toolchain in session state for agent reference.

## Common Pitfalls

**Mixing phases**:
- Refactoring while making test pass → Stick to minimal implementation
- Adding features while refactoring → Only improve structure, no behavior change

**Over-implementing**:
- Solving problems tests don't require → Write code only for current test
- Adding "obvious next features" → Let tests drive each feature

**Under-testing**:
- Tests too large or complex → Break into smaller tests
- Multiple behaviors per test → One new behavior per test

**Ignoring constraints**:
- Forgetting kata constraints during implementation → Review constraints before coding
- Applying constraints only during refactor → Apply from first test

## Additional Resources

### Reference Files

For detailed guidance, consult:
- **`references/object-calisthenics.md`** - Comprehensive constraint explanations with patterns and examples
- **`references/tdd-cycle-guide.md`** - Deep dive into each TDD phase with decision trees and troubleshooting

### Examples

Working examples demonstrating full TDD cycles:
- **`examples/fizzbuzz/`** - Complete kata with commits showing RED-GREEN-REFACTOR progression (future addition)

## Quick Reference

**RED Phase Checklist**:
- [ ] Read commits + TODO.md
- [ ] Write failing test
- [ ] Verify test fails
- [ ] Update TODO.md
- [ ] Commit: `test: ...`

**GREEN Phase Checklist**:
- [ ] Read commits + TODO.md
- [ ] Write minimal code
- [ ] Verify test passes
- [ ] Update TODO.md
- [ ] Commit: `feat: ...`

**REFACTOR Phase Checklist**:
- [ ] Read commits + TODO.md
- [ ] Analyze code
- [ ] Refactor OR document why clean
- [ ] Keep tests green
- [ ] Update TODO.md
- [ ] Commit: `refactor: ...` (if changes)
- [ ] Ask: continue or complete?

---

Follow these principles and patterns to build TDD discipline through deliberate kata practice. The key is maintaining strict phase separation and learning from each cycle.
