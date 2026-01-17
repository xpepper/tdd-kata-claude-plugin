---
name: kata-add-constraint
description: Add a new kata constraint to the current session mid-practice
argument-hint: "<constraint-description>"
allowed-tools: ["Read", "Write", "Edit"]
---

# Kata Add Constraint Command

Add a new coding constraint to an active kata session, applying it from the next TDD cycle forward.

## Purpose

Allow users to increase difficulty or practice specific patterns by adding constraints mid-session. This is useful for:
- Progressive difficulty (start simple, add constraints as you go)
- Experimenting with specific patterns
- Practicing constraint application in existing code

## Execution Steps

### 1. Validate Active Session

Read `.tdd-session.json` to verify session exists.

**If no session**:
- Display: "No active kata session. Start one with /start-kata"
- Exit command

### 2. Get Constraint Description

**If constraint provided as argument**:
- Use the provided constraint text
- Example: `/kata-add-constraint "No getters or setters"`

**If no argument provided**:
- Display: "Please provide a constraint description"
- Show common constraint examples:
  - One level of indentation per method
  - Don't use the ELSE keyword
  - Wrap all primitives and Strings
  - First class collections
  - One dot per line
  - Don't abbreviate names
  - Keep all entities small
  - No classes with more than two instance variables
  - No getters/setters/properties
- Exit command

### 3. Read Current Session State

Parse `.tdd-session.json` to get current constraints list.

### 4. Check for Duplicate

Compare new constraint against existing constraints:
- If exact match or very similar, warn user
- Ask: "This constraint seems similar to existing one. Add anyway?"

### 5. Add Constraint to Session

Update `.tdd-session.json`:
```json
{
  "phase": "...",
  "language": "...",
  "toolchain": {...},
  "constraints": [
    "existing constraint 1",
    "existing constraint 2",
    "newly added constraint"  // ← Added here
  ],
  "lastUpdated": "[new timestamp]"
}
```

Use Edit tool to update the constraints array and lastUpdated timestamp.

### 6. Update TODO.md

Add entry to lessons learned section documenting the constraint addition:

```markdown
## Lessons Learned
[...existing lessons...]
- **Constraint Added** ([timestamp]): "[constraint description]" - Apply in next cycles
```

### 7. Display Confirmation

Show user the updated constraint list:

```
✅ Constraint Added

New Constraint:
  • [constraint description]

All Active Constraints:
  1. [constraint 1]
  2. [constraint 2]
  3. [newly added constraint]

📝 Note: This constraint applies starting from the next TDD cycle.
     Current cycle can continue without it.

💡 Tip: Agents will see this constraint and apply it in future cycles.
     Consider if existing code needs refactoring to meet this constraint.
```

### 8. Suggest Next Steps

Based on current phase:

**If RED or GREEN phase (mid-cycle)**:
```
Suggested Actions:
  • Complete current RED-GREEN-REFACTOR cycle
  • In next REFACTOR phase, consider if code violates new constraint
  • Apply constraint starting with next test
```

**If REFACTOR phase**:
```
Suggested Actions:
  • Consider refactoring current code to meet new constraint now
  • Or apply constraint starting with next test
  • Document decision in lessons learned
```

**If COMPLETE phase**:
```
Suggested Actions:
  • Session is marked complete
  • Restart with /start-kata to practice with new constraint set
```

## Constraint Application Guidance

### Common Constraints

Provide brief explanation if user adds a well-known constraint:

**"One level of indentation"**:
```
This constraint encourages:
  • Small, focused methods
  • Extract Method refactoring
  • Composed Method pattern

See references/object-calisthenics.md for details.
```

**"No else keyword"**:
```
This constraint encourages:
  • Guard clauses / early returns
  • Polymorphism
  • Strategy pattern

See references/object-calisthenics.md for details.
```

**"Wrap all primitives"**:
```
This constraint encourages:
  • Value Objects
  • Domain-Driven Design
  • Type safety

See references/object-calisthenics.md for details.
```

(Include brief guidance for other common constraints)

### Custom Constraints

For custom constraints, prompt user:
```
Custom constraint added. Consider:
  • How will this constraint affect design decisions?
  • What patterns does it encourage?
  • Document insights in lessons learned as you apply it
```

## Validation

### Constraint Format

Ensure constraint is:
- Clear and actionable
- Not empty or too vague
- Written as a rule, not a suggestion

**Good constraints**:
- "No classes with more than 3 methods"
- "All methods must return a value (no void)"
- "No inheritance, use composition only"

**Vague constraints** (ask for clarification):
- "Write better code" (too vague)
- "Maybe use interfaces?" (not a rule)
- "Try to keep things simple" (not specific)

### Compatibility Check

Warn if new constraint conflicts with existing ones:
- "No getters/setters" + "Wrap all primitives" = Compatible ✅
- "Maximum 5 lines per method" + "One level of indentation" = Compatible ✅
- Custom constraint + existing constraints = Unknown (let user decide)

## Error Handling

**If session file is corrupted**:
- Display error
- Show file content
- Suggest manual fix
- Don't modify file

**If can't update session file**:
- Display error message
- Check file permissions
- Suggest manual edit

**If TODO.md doesn't exist**:
- Still update session state
- Create TODO.md with constraint note
- Continue execution

## Usage Examples

```bash
# Add a specific constraint
/kata-add-constraint "No getters or setters"

# Add custom constraint
/kata-add-constraint "All method names must be verbs"

# Add object calisthenics constraint
/kata-add-constraint "First class collections"
```

## Important Notes

- **Mid-session friendly**: Designed to add constraints without restarting
- **Applies forward**: New constraint affects future cycles, not current one
- **Agent-visible**: All agents will see and apply new constraints
- **Documented**: Constraint addition logged in lessons learned
- **Reversible**: Can be removed by editing .tdd-session.json manually

## Integration with Agents

Agents read session state at start of each phase:
1. Tester agent: Writes tests considering all constraints
2. Implementer agent: Implements following all constraints
3. Refactorer agent: Refactors to meet all constraints

Adding a constraint mid-session means agents will automatically apply it in next cycles.

---

Use this command to progressively increase kata difficulty and practice specific coding patterns.
