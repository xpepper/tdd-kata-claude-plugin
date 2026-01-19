# TDD Kata Plugin - Improvement Backlog

This file tracks potential improvements, feature requests, and enhancement ideas for the TDD Kata plugin. Items are organized by category and include priority indicators.

**Priority Levels:**
- 🔴 **High** - Critical for user experience or workflow
- 🟡 **Medium** - Valuable improvement, should be addressed soon
- 🟢 **Low** - Nice to have, can be deferred

---

## Features

### 🟡 YOLO Mode - Continuous TDD Flow

**Status:** Proposed
**Priority:** Medium
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
