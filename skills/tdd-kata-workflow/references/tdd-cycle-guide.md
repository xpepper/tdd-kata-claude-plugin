# TDD Cycle Deep Dive Guide

This reference provides detailed guidance for each phase of the Red-Green-Refactor cycle, including decision trees, troubleshooting, and advanced techniques.

## The TDD Rhythm

TDD operates in short cycles—typically 2-10 minutes per complete Red-Green-Refactor loop. This rhythm creates a sustainable pace and provides rapid feedback.

**Cycle timing guidelines**:
- RED: 1-3 minutes (write test, verify failure)
- GREEN: 1-5 minutes (minimal implementation)
- REFACTOR: 1-5 minutes (improve structure)

If a phase takes longer, the test might be too large. Consider breaking it into smaller tests.

## RED Phase: Write a Failing Test

### Purpose

The RED phase specifies what the code should do before writing any implementation. The failing test proves that:
1. The test actually tests something
2. The production code doesn't accidentally already have this behavior
3. The test will detect if this behavior breaks in the future

### Step-by-Step Process

**1. Read Context**
- Review recent commits to understand what's been built
- Check TODO.md for planned behaviors
- Understand kata constraints that apply

**2. Choose Next Behavior**
- Pick the simplest next behavior to implement
- Follow the "Transformation Priority Premise" if applicable
- Consider what will teach you the most about the problem

**3. Write the Test**
```python
# Example: FizzBuzz kata, first test
def test_returns_one_for_input_one():
    assert fizzbuzz(1) == "1"
```

**4. Run the Test**
- Execute test framework
- Verify it fails (compilation error or assertion failure)
- Check failure message is clear

**5. Analyze Failure**
- Expected: Test fails because behavior not implemented
- Unexpected: Test passes → Investigate why
- Unexpected: Wrong error → Fix test

**6. Update TODO**
- Mark test as written
- Add any new behaviors discovered
- Document any surprises

**7. Commit**
```bash
git add .
git commit -m "test: verify fizzbuzz returns '1' for input 1"
```

### Decision Tree: Choosing Next Test

```
Start
  ↓
Does code handle any inputs yet?
  ├─ No → Write simplest possible test (e.g., constant case)
  └─ Yes → Continue
         ↓
    Are there obvious edge cases?
      ├─ Yes → Test edge case
      └─ No → Continue
             ↓
        Does current logic generalize?
          ├─ No → Add test forcing generalization
          └─ Yes → Test next feature
```

**Example: FizzBuzz progression**
1. Input 1 returns "1" (simplest case - constant)
2. Input 2 returns "2" (force generalization from constant)
3. Input 3 returns "Fizz" (first special rule)
4. Input 5 returns "Buzz" (second special rule)
5. Input 15 returns "FizzBuzz" (combination rule)

### Transformation Priority Premise

When choosing next tests, prefer simpler transformations over complex ones:

1. **Constant** → `return "1"`
2. **Constant to Variable** → `return n.toString()`
3. **Unconditional to Conditional** → `if (n == 3) return "Fizz"`
4. **Scalar to Array** → `items.forEach(...)`
5. **Array to Container** → Using a data structure
6. **Conditional to Iteration** → `for` or `while` loop
7. **Statement to Recursion** → Recursive call

Write tests in order that encourage these transformations from simple to complex.

### Common RED Phase Mistakes

**Test too large**:
```python
# ❌ Too many concepts
def test_fizzbuzz():
    assert fizzbuzz(1) == "1"
    assert fizzbuzz(3) == "Fizz"
    assert fizzbuzz(5) == "Buzz"
    assert fizzbuzz(15) == "FizzBuzz"

# ✅ One concept per test
def test_returns_string_for_regular_numbers():
    assert fizzbuzz(1) == "1"
```

**Test coupled to implementation**:
```java
// ❌ Testing internal structure
@Test
public void testUsesMapToStoreMappings() {
    FizzBuzz fb = new FizzBuzz();
    assertTrue(fb.mappings instanceof HashMap);
}

// ✅ Testing behavior
@Test
public void testReturnsStringForInput() {
    assertEquals("1", new FizzBuzz().convert(1));
}
```

**Test not actually failing**:
```typescript
// ❌ Test passes immediately (wrong assertion)
test('returns Fizz for 3', () => {
    expect(fizzbuzz(3)).toBeTruthy(); // "Fizz" is truthy, passes without implementation
});

// ✅ Specific assertion
test('returns Fizz for 3', () => {
    expect(fizzbuzz(3)).toBe("Fizz");
});
```

### Troubleshooting RED Phase

**Problem: Test passes immediately**

Possible causes:
1. Previous implementation over-solved
2. Refactoring changed behavior
3. Test doesn't actually test new behavior

Actions:
1. Analyze what's causing the pass
2. Document in TODO.md lessons learned
3. Either fix test to fail, or remove over-implementation
4. Never proceed with a test that should fail but doesn't

**Problem: Can't think of next test**

Solutions:
1. Review kata description for untested requirements
2. Think of edge cases (empty, negative, null, maximum)
3. Consider error conditions
4. Ask: "What can break my current implementation?"
5. If truly stuck, refactor current code or consider kata complete

**Problem: Test requires too much setup**

Solutions:
1. Test might be too large—break into smaller tests
2. Use test data builders or factories
3. Create test helper methods
4. Revisit design—complex setup indicates design issues

## GREEN Phase: Make It Pass

### Purpose

The GREEN phase implements just enough code to pass the failing test. Speed over elegance is the goal. This phase builds production code incrementally, guided by tests.

### Step-by-Step Process

**1. Read Context**
- Review the failing test
- Check recent commits
- Read TODO.md for context

**2. Choose Implementation Strategy**

Three strategies, in order of preference:

**Fake It (Constant)**
```python
# Test: fizzbuzz(1) == "1"
def fizzbuzz(n):
    return "1"  # Simplest thing that works
```

**Obvious Implementation**
```python
# Test: fizzbuzz(2) == "2"
def fizzbuzz(n):
    return str(n)  # Generalize when test demands it
```

**Triangulation**
```python
# After tests for 1, 2, and 3:
def fizzbuzz(n):
    if n == 3:
        return "Fizz"
    return str(n)
```

**3. Write Minimal Code**
- Make the test pass with simplest possible code
- Don't solve problems tests don't require
- Apply kata constraints from the start
- Resist the urge to add "obvious" features

**4. Run Tests**
- Execute full test suite
- Verify all tests pass, including the new one
- If failures, fix until all green

**5. Update TODO**
- Mark implementation complete
- Add any complexity discovered
- Note if implementation was harder than expected

**6. Commit**
```bash
git add .
git commit -m "feat: implement fizzbuzz conversion for regular numbers"
```

### Decision Tree: Implementation Strategy

```
Start: I have a failing test
  ↓
Is the implementation obvious and simple?
  ├─ Yes → Write obvious implementation
  └─ No → Continue
         ↓
    Is this the first test?
      ├─ Yes → Return a constant (fake it)
      └─ No → Continue
             ↓
        Will triangulation help?
          ├─ Yes → Keep simple, wait for more tests
          └─ No → Write minimal generalization
```

### The Three Strategies Explained

**1. Fake It (Return a Constant)**

Use when writing the very first test or when genuinely unsure how to generalize.

```rust
// Test: calculate_discount(customer) for regular customer
#[test]
fn test_regular_customer_discount() {
    let discount = calculate_discount(RegularCustomer);
    assert_eq!(discount, 0.0);
}

// Implementation: Fake it
fn calculate_discount(customer: Customer) -> f64 {
    0.0  // Hardcode the expected value
}
```

**Why it works**: Next test will force you to generalize, but for now, this proves the test works.

**2. Obvious Implementation**

Use when the implementation is genuinely simple and clear.

```java
// Test: adding two numbers
@Test
public void testAddsTwoNumbers() {
    assertEquals(5, calculator.add(2, 3));
}

// Implementation: Obvious
public int add(int a, int b) {
    return a + b;  // Simple and clear
}
```

**Why it works**: No point faking it when the real implementation is this simple.

**3. Triangulation**

Use when you need more examples to understand the pattern.

```typescript
// Test 1: one item
test('calculates total for one item', () => {
    expect(calculateTotal([10])).toBe(10);
});

// Implementation 1: Fake it
function calculateTotal(items: number[]): number {
    return 10;
}

// Test 2: two items
test('calculates total for two items', () => {
    expect(calculateTotal([10, 20])).toBe(30);
});

// Implementation 2: Now generalize (triangulated by two tests)
function calculateTotal(items: number[]): number {
    return items.reduce((sum, item) => sum + item, 0);
}
```

**Why it works**: Multiple tests clarify the pattern before committing to an implementation.

### Minimal vs Over-Implementation

**Minimal (good)**:
```python
# Test: return "Fizz" for 3
def test_returns_fizz_for_three():
    assert fizzbuzz(3) == "Fizz"

# Minimal implementation
def fizzbuzz(n):
    if n == 3:
        return "Fizz"
    return str(n)
```

**Over-implementation (bad)**:
```python
# Test: return "Fizz" for 3
def test_returns_fizz_for_three():
    assert fizzbuzz(3) == "Fizz"

# Over-implementation (no test for multiples yet!)
def fizzbuzz(n):
    if n % 3 == 0:  # ❌ Generalizes too early
        return "Fizz"
    return str(n)
```

**Why bad**: No test requires modulo logic yet. Write `n == 3` first, generalize when a test for `n == 6` arrives.

### Applying Constraints During GREEN

Apply kata constraints during implementation, not as a later refactoring:

**Without constraints**:
```java
// First implementation
public String process(int n) {
    if (n == 3) {
        return "Fizz";
    } else {  // ❌ Used ELSE (violates constraint)
        return String.valueOf(n);
    }
}
```

**With constraints**:
```java
// First implementation following "no else" constraint
public String process(int n) {
    if (n == 3) {
        return "Fizz";
    }
    return String.valueOf(n);  // ✅ No else, guard clause pattern
}
```

### Common GREEN Phase Mistakes

**Adding features not required by tests**:
```python
# ❌ Over-implementation
def fizzbuzz(n):
    if n < 1:  # No test requires this
        raise ValueError("Input must be positive")
    if n % 15 == 0:  # No test for 15 yet
        return "FizzBuzz"
    if n % 3 == 0:
        return "Fizz"
    return str(n)

# ✅ Only what tests require
def fizzbuzz(n):
    if n == 3:
        return "Fizz"
    return str(n)
```

**Premature abstraction**:
```java
// ❌ Creating abstractions too early
public interface NumberConverter {
    String convert(int n);
}

public class FizzBuzzConverter implements NumberConverter {
    // ... only one test exists
}

// ✅ Keep it simple
public class FizzBuzz {
    public String convert(int n) {
        if (n == 3) return "Fizz";
        return String.valueOf(n);
    }
}
```

**Refactoring while implementing**:
```typescript
// ❌ Mixing phases
function fizzbuzz(n: number): string {
    if (n === 3) return "Fizz";
    return String(n);
}

// "This could be cleaner, let me refactor..."
// NO! Get to green first, refactor in REFACTOR phase

// ✅ Get to green, refactor later
function fizzbuzz(n: number): string {
    if (n === 3) return "Fizz";  // Get this working
    return String(n);  // Refactor in next phase if needed
}
```

### Troubleshooting GREEN Phase

**Problem: Implementation getting complex**

Actions:
1. Step back—is the test too large?
2. Break test into smaller tests
3. Accept complexity for now, simplify in REFACTOR
4. Consider if missing an intermediate test

**Problem: Not sure how to make test pass**

Solutions:
1. Start with fake it (return constant)
2. Write simplest thing, even if ugly
3. Get to green first, improve in REFACTOR
4. Try test-driving helper methods

**Problem: Breaking other tests**

Actions:
1. Check if breaking existing behavior
2. Fix to pass all tests
3. Consider if refactoring needed
4. May indicate test is too large

## REFACTOR Phase: Improve Design

### Purpose

The REFACTOR phase improves code structure while maintaining behavior. With green tests as a safety net, confidently transform code to be clearer, simpler, and more maintainable.

### Step-by-Step Process

**1. Read Context**
- Review recent commits
- Check TODO.md for context
- Understand current code structure

**2. Analyze Code**

Look for:
- **Duplication**: Same logic in multiple places
- **Poor names**: Variables/methods that don't express intent
- **Complexity**: Methods too long or deeply nested
- **Constraint violations**: Object calisthenics rules broken
- **Preparatory refactoring**: Changes that will ease next features

**3. Decide: Refactor or Skip**

**Refactor if**:
- Duplication exists
- Names are unclear
- Methods are too complex
- Constraints are violated
- Current structure resists likely next changes

**Skip if**:
- Code is clean and clear
- Structure accommodates next changes easily
- No duplication
- All constraints satisfied

**4. Refactor (if needed)**

**Critical rule**: Keep tests green throughout

Process:
1. Make one small change
2. Run tests
3. If green, continue
4. If red, undo and try differently
5. Repeat

**5. Update TODO**

Whether refactoring or skipping:
- Document decision
- Add lessons learned
- Note what was improved or why clean

**6. Commit (if changes made)**
```bash
git add .
git commit -m "refactor: extract fizz logic to separate method"
```

**7. Ask User: Continue or Complete?**

After refactoring, check with user:
- Continue → Launch Tester agent for next cycle
- Complete → Mark kata finished

### Refactoring Techniques

**Extract Method**

```python
# Before: Complex method
def fizzbuzz(n):
    if n % 15 == 0:
        return "FizzBuzz"
    if n % 3 == 0:
        return "Fizz"
    if n % 5 == 0:
        return "Buzz"
    return str(n)

# After: Extracted methods
def fizzbuzz(n):
    if is_fizzbuzz(n):
        return "FizzBuzz"
    if is_fizz(n):
        return "Fizz"
    if is_buzz(n):
        return "Buzz"
    return str(n)

def is_fizz(n):
    return n % 3 == 0

def is_buzz(n):
    return n % 5 == 0

def is_fizzbuzz(n):
    return is_fizz(n) and is_buzz(n)
```

**Rename**

```java
// Before: Unclear names
public String p(int x) {
    if (x % 3 == 0) return "Fizz";
    return String.valueOf(x);
}

// After: Clear names
public String convert(int number) {
    if (isDivisibleByThree(number)) return "Fizz";
    return String.valueOf(number);
}
```

**Remove Duplication**

```rust
// Before: Duplication
fn is_fizz(n: i32) -> bool {
    n % 3 == 0
}

fn is_buzz(n: i32) -> bool {
    n % 5 == 0
}

// After: Extract common pattern
fn is_divisible_by(n: i32, divisor: i32) -> bool {
    n % divisor == 0
}

fn is_fizz(n: i32) -> bool {
    is_divisible_by(n, 3)
}

fn is_buzz(n: i32) -> bool {
    is_divisible_by(n, 5)
}
```

**Apply Constraint**

```typescript
// Before: Violates "no else"
function convert(n: number): string {
    if (n % 3 === 0) {
        return "Fizz";
    } else {
        return String(n);
    }
}

// After: Guard clause pattern
function convert(n: number): string {
    if (n % 3 === 0) {
        return "Fizz";
    }

    return String(n);
}
```

### Preparatory Refactoring

Sometimes refactor not to clean current code, but to make the next change easier.

**Example**: Before adding "Buzz" logic, extract Fizz handling:

```python
# Current (works for Fizz):
def fizzbuzz(n):
    if n % 3 == 0:
        return "Fizz"
    return str(n)

# Preparatory refactoring (makes adding Buzz easier):
def fizzbuzz(n):
    result = check_special_cases(n)
    if result:
        return result
    return str(n)

def check_special_cases(n):
    if n % 3 == 0:
        return "Fizz"
    return None

# Now adding Buzz is straightforward:
def check_special_cases(n):
    if n % 3 == 0:
        return "Fizz"
    if n % 5 == 0:  # Easy to add
        return "Buzz"
    return None
```

Document preparatory refactoring in TODO.md:
```markdown
## Lessons Learned
- Extracted special case logic to make adding Buzz rule easier
- Structure now accommodates additional rules without modification
```

### When to Skip Refactoring

**Code is already clean**:
```python
def fizzbuzz(n):
    if is_fizz(n):
        return "Fizz"
    return str(n)

def is_fizz(n):
    return n % 3 == 0
```

Document in TODO.md:
```markdown
## Lessons Learned
- No refactoring needed this cycle
- Code is clean: methods are small, names are clear, no duplication
- Current structure will easily accommodate Buzz rule in next cycle
```

### Common REFACTOR Phase Mistakes

**Changing behavior**:
```java
// ❌ Changing logic during refactor
// Before
if (n % 3 == 0) return "Fizz";

// After (❌ changed behavior!)
if (n % 3 == 0 && n % 5 != 0) return "Fizz";  // Added condition

// ✅ Only structure changes
// Before
if (n % 3 == 0) return "Fizz";

// After (✅ same behavior, better structure)
if (isDivisibleByThree(n)) return "Fizz";
```

**Big-bang refactoring**:
```python
# ❌ Too many changes at once
# Renamed variables, extracted methods, changed structure all at once
# If tests fail, which change broke it?

# ✅ Incremental refactoring
# 1. Rename variable → run tests → commit
# 2. Extract method → run tests → commit
# 3. Change structure → run tests → commit
```

**Refactoring before green**:
```typescript
// ❌ Test is red, but trying to refactor
test('returns Fizz for 3', () => {
    expect(fizzbuzz(3)).toBe("Fizz");
}); // FAILING

// NO! Get to green first

// ✅ Get to green, then refactor
// 1. Make test pass with any code
// 2. Tests are green
// 3. Now refactor
```

### Refactoring Safety

**Always keep tests green**:
1. Make small change
2. Run tests immediately
3. Green → continue
4. Red → undo change
5. Commit after each successful refactoring

**Use version control**:
```bash
# After each safe refactoring
git add .
git commit -m "refactor: extract is_fizz method"

# If refactoring breaks tests, can easily revert
git reset --hard HEAD
```

### Troubleshooting REFACTOR Phase

**Problem: Tests break during refactoring**

Actions:
1. Undo the change (git reset or Ctrl+Z)
2. Take smaller steps
3. Run tests more frequently
4. Consider if trying to change behavior

**Problem: Don't know what to refactor**

Solutions:
1. Look for duplication first (easiest to spot)
2. Check for constraint violations
3. Read code aloud—unclear parts need better names
4. If nothing stands out, code might be clean—document and skip

**Problem: Refactoring feels like it's taking too long**

Actions:
1. Scope might be too large—pick one small improvement
2. Get to a safe state (green tests) and commit
3. Continue refactoring in next cycle if needed
4. Document current state in TODO.md

## Cross-Phase Guidelines

### Keeping Tests Green

**Golden rule**: Tests should always be green except during RED phase.

```
RED → Test fails (expected) → GREEN → Tests pass → REFACTOR → Tests stay green
```

If tests go red during GREEN or REFACTOR, stop and fix immediately.

### Commit Discipline

Commit after every phase completion:
- RED: After test written and verified failing
- GREEN: After implementation makes tests pass
- REFACTOR: After each successful refactoring (or document if skipped)

**Benefits**:
- Creates clear history for next agent
- Enables easy rollback if needed
- Documents progression through kata

### TODO.md Maintenance

Update TODO.md throughout every phase:

**RED phase**:
```markdown
## Current Task
- [ ] Write test for Buzz rule

## Lessons Learned
- Added test for 5 returning "Buzz"
```

**GREEN phase**:
```markdown
## Current Task
- [x] Write test for Buzz rule
- [ ] Implement Buzz rule

## Lessons Learned
- Implementation straightforward, followed same pattern as Fizz
```

**REFACTOR phase**:
```markdown
## Completed Tasks
- [x] Write test for Buzz rule
- [x] Implement Buzz rule

## Lessons Learned
- Extracted common divisibility check to reduce duplication
- Structure now handles any number of rules easily
```

## Advanced Techniques

### Test List

Maintain a running list of tests to write:

```markdown
## Planned Tests
- [ ] 1 returns "1"
- [ ] 2 returns "2"
- [ ] 3 returns "Fizz"
- [ ] 5 returns "Buzz"
- [ ] 15 returns "FizzBuzz"
- [ ] 6 returns "Fizz" (multiple of 3)
- [ ] Negative numbers?
- [ ] Zero?
```

Update as you discover new cases.

### Spike and Revert

If unsure how to implement:
1. Create a throwaway "spike" to explore
2. Don't commit the spike
3. Revert the code
4. Write proper tests based on learning
5. Implement with TDD

### Baby Steps

When stuck, take even smaller steps:
- Write test that will obviously pass (to verify test works)
- Return constant first, generalize second
- One-line changes only
- Run tests after every single change

## Summary Checklist

**RED Phase**:
- [ ] Read commits and TODO.md
- [ ] Choose simplest next behavior
- [ ] Write test
- [ ] Verify test fails
- [ ] Update TODO.md
- [ ] Commit: `test: ...`

**GREEN Phase**:
- [ ] Read commits and TODO.md
- [ ] Choose strategy (fake/obvious/triangulation)
- [ ] Write minimal code
- [ ] Verify all tests pass
- [ ] Update TODO.md
- [ ] Commit: `feat: ...`

**REFACTOR Phase**:
- [ ] Read commits and TODO.md
- [ ] Analyze code
- [ ] Decide refactor or skip
- [ ] If refactoring: small steps, keep tests green
- [ ] Update TODO.md (whether refactoring or skipping)
- [ ] Commit if changes made: `refactor: ...`
- [ ] Ask: continue or complete?

Follow this rhythm to build TDD muscle memory through deliberate kata practice.
