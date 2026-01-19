# TDD Kata Plugin - Improvement Backlog

This file tracks potential improvements, feature requests, and enhancement ideas for the TDD Kata plugin. Items are organized by category and include priority indicators.

**Priority Levels:**
- 🔴 **High** - Critical for user experience or workflow
- 🟡 **Medium** - Valuable improvement, should be addressed soon
- 🟢 **Low** - Nice to have, can be deferred

---

## Features

### 🔴 YOLO Mode - Continuous TDD Flow

**Status:** Proposed
**Priority:** High
**Category:** Feature

**Description:**
Add a "YOLO mode" where the TDD workflow continues automatically through multiple cycles without user intervention until the kata is complete.

**Current Behavior:**
- After each REFACTOR phase, refactorer agent asks user to continue or complete
- User must manually indicate decision
- Session enters "awaiting_decision" phase
- Requires running `/kata-status` to resume

**Proposed Behavior:**
- User can start kata with a flag: `/start-kata kata.md --yolo` or `/start-kata kata.md --auto-continue`
- Session tracks this mode in `.tdd-session.json`: `"mode": "yolo"`
- After REFACTOR phase, refactorer agent automatically:
  - Updates phase to 'red'
  - Launches tester agent for next cycle
  - No user prompt required
- Continues until:
  - All planned behaviors from TODO.md are complete, OR
  - User explicitly stops with `/kata-status` or `/complete-kata`, OR
  - No clear next behavior can be identified

**Implementation Notes:**
- Add `mode` field to session JSON schema: `"mode": "normal" | "yolo"`
- Update refactorer agent to check mode before prompting
- Add command-line argument parsing to start-kata command
- Consider safety: limit to N cycles to prevent runaway execution?

**Benefits:**
- Faster kata practice for experienced users
- Better for demonstrating TDD flow
- Useful for time-boxed kata sessions
- Reduces context switching

**Related:**
- Could add intermediate mode: "semi-auto" that pauses after N cycles
- Could add `/toggle-yolo` command to switch modes mid-session

---

### 🟡 Kata Library Integration

**Status:** Proposed
**Priority:** Medium
**Category:** Feature

**Description:**
Integrate with well-known kata repositories to allow users to browse, discover, and start katas directly from the plugin without manually copying descriptions.

**Current Behavior:**
- Users must manually find kata descriptions online
- Copy kata text from sources like:
  - https://www.codurance.com/katas
  - https://github.com/emilybache (Gilded Rose, Tennis Refactoring, etc.)
  - https://github.com/gamontal/awesome-katas
- Paste into `/start-kata` command or create local .md files
- No discovery mechanism for new/different katas

**Proposed Behavior:**
1. **Kata Browser Command:**
   ```bash
   /browse-katas
   # Shows categories: Classic, Refactoring, Algorithm, Game, etc.

   /browse-katas --source codurance
   # Filter by source

   /browse-katas --difficulty beginner
   # Filter by difficulty level
   ```

2. **Quick Start from Library:**
   ```bash
   /start-kata fizzbuzz
   # Looks up FizzBuzz from built-in library

   /start-kata "gilded-rose" --source emily-bache
   # Starts Emily Bache's Gilded Rose kata

   /start-kata tennis --language rust
   # Starts Tennis kata in Rust
   ```

3. **Kata Metadata Storage:**
   - Build internal kata library with structured metadata:
     ```json
     {
       "id": "fizzbuzz",
       "name": "FizzBuzz",
       "source": "classic",
       "url": "https://...",
       "difficulty": "beginner",
       "categories": ["algorithm", "tdd-intro"],
       "languages": ["any"],
       "estimatedTime": "15-30min",
       "description": "...",
       "suggestedConstraints": ["no-conditionals", "one-level-indentation"]
     }
     ```

4. **Kata Discovery Features:**
   - Search by name, category, difficulty
   - "Random kata" command for practice
   - "Next recommended kata" based on completed katas
   - Show kata completion history

**Implementation Notes:**
- Start with curated list of ~20-30 popular katas
- Store kata definitions in `katas/` directory as JSON or YAML files
- Add `/browse-katas` and `/start-kata <kata-id>` commands
- Track completed katas in `.tdd-session-history.json` or similar
- Consider: GitHub integration to fetch kata descriptions dynamically?
- Consider: User-contributed kata library (like a marketplace)

**Benefits:**
- **Removes friction** - users can start practicing immediately
- **Discovery** - exposes users to katas they haven't tried
- **Consistency** - standardized kata descriptions
- **Progression** - can track which katas completed, suggest next steps
- **Community** - shared kata library, everyone practices same material
- **Supports "TDD machine" goal** - easy access to diverse practice material

**Related:**
- Pairs well with "Kata Difficulty Progression" feature
- Could integrate with external APIs (Codewars, Exercism, etc.)
- Metadata enables filtering by paradigm, language, style

---

### 🟡 TDD Style Selector

**Status:** Proposed
**Priority:** Medium
**Category:** Feature

**Description:**
Allow users to explicitly select and enforce different TDD styles/approaches (Classic TDD, Chicago School, Outside-In/London School, Transformation Priority Premise) to practice different methodologies.

**Current Behavior:**
- Plugin documentation mentions different TDD styles (.github/copilot-instructions.md:106-114)
- Default behavior uses Transformation Priority Premise in tester agent
- No way to select or enforce specific style
- User must manually tell agents to follow different approach
- Agents don't consistently enforce style constraints

**Proposed Behavior:**
1. **Style Selection at Startup:**
   ```bash
   /start-kata fizzbuzz --style classic
   # Kent Beck style: simplest thing, from known to unknown

   /start-kata banking --style outside-in
   # London School: start with acceptance test, work inward with mocks

   /start-kata gilded-rose --style tpp
   # Transformation Priority Premise (current default)
   ```

2. **Style-Specific Agent Behavior:**
   - **Classic TDD (Kent Beck):**
     - Tester: Choose obvious next test, simple progression
     - Implementer: Simplest thing that could possibly work
     - Emphasis on learning through exploration

   - **Chicago School:**
     - Minimize mocking, use real objects when possible
     - Mock only external dependencies
     - State verification over interaction verification

   - **Outside-In (London School):**
     - Start with high-level acceptance test
     - Work inward, defining collaborators as you go
     - Heavy use of mocks for collaborators
     - Tester focuses on behavior/interactions

   - **Transformation Priority Premise:**
     - Current default behavior
     - Strict transformation ordering
     - Test selection based on simplest transformation

3. **Style-Specific Constraints:**
   - Store style in `.tdd-session.json`: `"tddStyle": "outside-in"`
   - Agents read style and adapt behavior
   - Style-specific validation in hooks
   - Different commit message patterns per style?

4. **Educational Mode:**
   ```bash
   /explain-style outside-in
   # Shows principles, when to use, trade-offs

   /compare-styles classic vs outside-in
   # Educational comparison
   ```

**Implementation Notes:**
- Add `tddStyle` field to session JSON
- Create style-specific instruction variants for each agent
- Add command-line argument to start-kata
- Document each style's principles and trade-offs
- Could use AskUserQuestion to let user choose interactively
- Tester agent needs most significant changes (test selection strategy)

**Benefits:**
- **Learning tool** - practice different TDD approaches
- **Flexibility** - match style to kata type (Outside-In for features, Classic for algorithms)
- **Skill building** - master multiple methodologies
- **Real-world preparation** - different teams use different styles
- **Supports "TDD machine" goal** - enables diverse practice scenarios

**Related:**
- Different styles work better with different paradigms
- Some katas naturally fit certain styles better
- Could track which styles user has practiced

---

## Enhancements

### 🔴 Kata Description Persistence and Agent Awareness

**Status:** Proposed
**Priority:** High
**Category:** Enhancement

**Description:**
Ensure all agents have access to and consider the original kata description throughout the session, regardless of whether it was provided as a file or inline text.

**Current Behavior:**
- Kata description provided at session start via:
  - File path: `/start-kata path/to/kata.md`
  - Inline: `/start-kata` (then paste description)
- Description is parsed to extract constraints and requirements
- **Problem:** Not explicitly stored in `.tdd-session.json`
- **Problem:** Agents may not consistently refer back to original requirements
- **Problem:** If session is resumed later, kata context may be lost

**Proposed Behavior:**
1. **Store Kata Description:**
   - Add to `.tdd-session.json`:
     ```json
     {
       "kata": {
         "name": "FizzBuzz",
         "description": "Write a program that...",
         "descriptionPath": "kata.md",  // if from file
         "examples": ["1 -> '1'", "3 -> 'Fizz'", ...],
         "acceptanceCriteria": [...]
       }
     }
     ```

2. **Agent Instructions:**
   - Update all three agent files (tester, implementer, refactorer) to:
     - Explicitly read kata description from session at start of each phase
     - Reference it in "Session Context Files" section
     - Remind agents to validate against original requirements

3. **Session Start Hook:**
   - If kata description file exists, display summary in hook message
   - Remind user of current behavior being implemented

**Implementation Approach:**

1. **Modify start-kata command:**
   - Parse full kata description (not just constraints)
   - Extract: name, description text, examples, acceptance criteria
   - Store in `.tdd-session.json` under `kata` object

2. **Update agent instructions:**
   ```markdown
   ## Session Context Files

   Read these to understand current state:
   - **Kata description** from `.tdd-session.json` -> `kata.description` - THE SOURCE OF TRUTH for requirements
   - `.tdd-session.json` - phase, constraints, session state
   - ...
   ```

3. **Add validation prompts:**
   - Tester: "Does this test behavior align with kata requirements?"
   - Implementer: "Does this implementation match kata acceptance criteria?"
   - Refactorer: "Does refactoring preserve kata requirements?"

**Benefits:**
- Prevents scope creep (agents won't add features not in kata)
- Enables session resumption with full context
- Improves agent behavior selection (aligned with kata goals)
- Makes it clear what "done" means

**Related Issues:**
- Agents sometimes implement features not requested in kata
- Hard to resume session after days/weeks without re-reading kata file
- TODO.md lessons learned don't capture original requirements

---

### 🟢 Constraint Library & Presets

**Status:** Proposed
**Priority:** Low
**Category:** Enhancement

**Description:**
Expand beyond Object Calisthenics to include a library of predefined constraint sets that users can apply to make katas more challenging and practice different coding disciplines.

**Current Behavior:**
- Only Object Calisthenics constraints are well-supported
- Plugin references object-calisthenics.md with 9 rules
- Users can add custom constraints via `/kata-add-constraint`
- No other predefined constraint sets available
- Constraints are free-text, not validated or explained

**Proposed Behavior:**
1. **Predefined Constraint Sets:**
   ```bash
   /start-kata fizzbuzz --constraints object-calisthenics
   /start-kata banking --constraints functional-core
   /start-kata game --constraints tell-dont-ask
   /start-kata refactor --constraints solid-principles
   ```

2. **Constraint Library:**
   - **Object Calisthenics** (existing):
     - One level of indentation
     - No ELSE keyword
     - Wrap primitives
     - First class collections
     - One dot per line
     - etc.

   - **Functional Core, Imperative Shell:**
     - Pure functions for logic
     - I/O pushed to boundaries
     - Immutable data structures
     - No side effects in core domain

   - **Tell, Don't Ask:**
     - Methods tell objects what to do
     - Don't query state then make decisions
     - Objects make own decisions
     - Encapsulation over exposition

   - **No Primitives Obsession:**
     - Wrap all primitives in value objects
     - Strong typing for domain concepts
     - No naked strings/numbers/booleans

   - **SOLID Enforcement:**
     - Single Responsibility per class
     - Open/Closed for extension
     - Liskov Substitution
     - Interface Segregation
     - Dependency Inversion

   - **Immutability First:**
     - All data structures immutable
     - No mutating methods
     - Return new instances
     - Language-specific patterns (Rust ownership, etc.)

   - **No Null/Nil:**
     - Use Option/Maybe types
     - Explicit error handling
     - No null checks

3. **Constraint Mixing:**
   ```bash
   /start-kata fizzbuzz --constraints object-calisthenics,immutability
   # Combine multiple constraint sets
   ```

4. **Constraint Documentation:**
   ```bash
   /explain-constraints functional-core
   # Shows principles, examples, why it matters
   ```

**Implementation Notes:**
- Create `skills/tdd-kata-workflow/references/constraints/` directory
- One .md file per constraint set with:
  - Principles explanation
  - Specific rules
  - Examples in multiple languages
  - Common violations
  - Benefits/trade-offs
- Update start-kata to recognize `--constraints` flag
- Store selected constraints in `.tdd-session.json`
- Agents read and validate against constraints
- Could add constraint checker hooks?

**Benefits:**
- **Variety** - many ways to make katas challenging
- **Learning** - practice different design principles
- **Paradigm support** - functional constraints for FP katas
- **Customization** - mix constraints for unique challenges
- **Supports "TDD machine" goal** - enables practice with diverse constraints
- **Real-world skills** - constraints mirror real team standards

**Related:**
- Pairs with Multi-Paradigm Support (functional constraints for functional katas)
- Different languages suit different constraints better
- Some katas work better with specific constraints
- Could track which constraints user has practiced

---

### 🟡 Multi-Paradigm & Language Support Enhancement

**Status:** Proposed
**Priority:** Medium
**Category:** Enhancement

**Description:**
Enhance plugin to better support functional programming, different programming paradigms, and language-specific idioms beyond current OOP-centric approach.

**Current Behavior:**
- Plugin works well for OOP languages (Rust, TypeScript, Java)
- Default guidance assumes OOP patterns
- Object Calisthenics is OOP-focused
- Test patterns shown are mostly OOP-style (AAA, arrange-act-assert)
- No specific guidance for:
  - Pure functional languages (Haskell, Clojure, Elm, F#)
  - Logic programming (Prolog)
  - Concatenative languages (Forth, Factor)
  - Array programming (APL, J)

**Proposed Behavior:**
1. **Paradigm-Aware Agent Behavior:**
   - **Functional Programming:**
     - Tester: Focus on property-based tests, pure function contracts
     - Implementer: Use immutable data, higher-order functions, pattern matching
     - Refactorer: Look for opportunities to extract functions, use point-free style

   - **OOP (current default):**
     - Current behavior

   - **Procedural:**
     - Focus on function decomposition
     - Data structures separate from operations
     - Clear input/output contracts

2. **Language-Specific Test Patterns:**
   - **Rust:** Result/Option types, ownership tests, lifetime validation
   - **Haskell:** QuickCheck properties, type-driven development
   - **Clojure:** spec.test generative testing, REPL-driven development
   - **Python:** Hypothesis for property tests, duck typing tests
   - **TypeScript:** Type narrowing, discriminated unions

3. **Paradigm Selection:**
   ```bash
   /start-kata --language haskell --paradigm functional
   /start-kata --language rust --paradigm functional-core
   /start-kata --language python --paradigm oop
   ```

4. **Paradigm-Specific References:**
   - Create references for each paradigm:
     - `references/functional-testing-patterns.md`
     - `references/property-based-testing.md`
     - `references/fp-refactoring-catalog.md`
   - Agents reference appropriate guide based on paradigm

5. **Language Idiom Support:**
   - Detect language from session
   - Provide language-specific guidance:
     - Rust: borrow checker considerations, trait usage
     - Haskell: type classes, monads, laziness
     - Clojure: persistent data structures, transducers
     - Python: generators, context managers, decorators

**Implementation Notes:**
- Add `paradigm` field to `.tdd-session.json`
- Detect paradigm from language (Haskell → functional) or let user specify
- Create paradigm-specific variants of agent instructions
- Add language-specific reference files
- Update tester agent to suggest appropriate test approaches per paradigm
- Consider using different test frameworks per paradigm:
  - QuickCheck (Haskell)
  - Hypothesis (Python)
  - test.check (Clojure)
  - PropTest (Rust)

**Benefits:**
- **True multi-paradigm support** - not just OOP
- **Better for FP katas** - many Emily Bache katas have FP solutions
- **Language learning** - practice TDD in new paradigms
- **Real-world preparation** - many teams use functional patterns
- **Supports "TDD machine" goal** - handle diverse kata types from all sources
- **Correctness** - functional katas need different test strategies

**Related:**
- Pairs with Constraint Library (functional constraints)
- Pairs with TDD Style Selector (Outside-In works differently in FP)
- Enables katas from sources like Exercism (has FP tracks)
- Some katas naturally fit certain paradigms

---

## Bug Fixes

_No items currently tracked_

---

## Documentation

_No items currently tracked_

---

## Technical Debt

_No items currently tracked_

---

## Template for New Items

When adding new backlog items, use this template:

```markdown
### [Priority Emoji] Brief Title

**Status:** Proposed | In Progress | Blocked
**Priority:** High | Medium | Low
**Category:** Feature | Enhancement | Bug Fix | Documentation | Technical Debt

**Description:**
[Clear description of what needs to be done]

**Current Behavior:**
[How it works now, if applicable]

**Proposed Behavior:**
[How it should work]

**Implementation Notes:**
[Technical approach, considerations, constraints]

**Benefits:**
[Why this is valuable]

**Related:**
[Links to related items, issues, or commits]
```

---

## Contributing Ideas

Have an idea for improving the TDD Kata plugin?

1. Add it to this backlog using the template above
2. Open an issue on GitHub (if repository is available)
3. Discuss with maintainers before starting implementation

Remember: This plugin is about learning TDD discipline. New features should support that goal, not replace the human learning experience.
