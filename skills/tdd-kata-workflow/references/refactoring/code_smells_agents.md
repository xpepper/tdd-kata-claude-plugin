# code-smells.md (Agent Reference, compact)

Purpose: detect probable code smells, provide evidence, and propose low-risk refactorings in small, test-backed steps.

## Output schema (required)
For each smell reported, output:
- Smell:
- Location: file + symbol
- Evidence: 2+ concrete signals
- Confidence: High|Medium|Low
- Risk: Low|Medium|High
- Suggested refactorings (1-3):
- Counterexample check: why this is NOT a false positive

## Global rules (required)
1. Small diffs: one smell per change-set.
2. Preserve behaviour: add/strengthen tests before refactor when behaviour is non-trivial.
3. Do not refactor across public API boundaries unless explicitly instructed.
4. If Confidence is Low or Risk is High: propose only, do not apply.
5. Never remove code unless you can prove it is unused (compiler/linter/call sites/tests).

## Configurable thresholds (defaults)
- LongMethodLOC: 40
- MaxNesting: 3
- MaxComplexity: 15
- LongParamArity: 5
(Adjust per language/repo.)

## Core smells (use these by default)

### Long Method
- Heuristics:
  - LOC > LongMethodLOC AND (complexity > 10 OR nesting > MaxNesting)
  - many locals (> 12) or mixed responsibilities (unrelated domain nouns)
- Counterexamples:
  - straight-line mapping/serialisation with low complexity
- Refactorings:
  - Extract Method, guard clauses, decompose by case

### Deep Nesting
- Heuristics:
  - nesting_depth > MaxNesting
  - nested match/if with repeated else blocks
- Counterexamples:
  - parser/visitor code reflecting grammar, well tested
- Refactorings:
  - guard clauses, extract method, flatten control flow

### High Cyclomatic Complexity
- Heuristics:
  - complexity > MaxComplexity OR branches > 20
- Counterexamples:
  - dispatcher that delegates to small handlers
- Refactorings:
  - decompose by case, extract predicates, data-driven dispatch

### Duplicate Code
- Heuristics:
  - high token/AST similarity across 2+ regions
  - same call sequence with minor literal differences
- Counterexamples:
  - intentional divergence (performance/policy) with tests or explicit rationale
- Refactorings:
  - extract helper, parameterise differences, shared module

### Long Parameter List
- Heuristics:
  - arity > LongParamArity OR 2+ boolean params
  - call sites pass many literals ("", 0, true)
- Counterexamples:
  - internal helper with stable call sites and strong types
- Refactorings:
  - parameter object (struct/record), replace booleans with enum, builder/config

### Data Clumps
- Heuristics:
  - same 2-4 fields appear together across 3+ functions/types
- Counterexamples:
  - boundary DTO shapes; well-known stable identity pairs (id, tenant_id)
- Refactorings:
  - extract value object, parameter object

### Primitive Obsession
- Heuristics:
  - semantic IDs/units represented as primitives in domain layer
  - repeated parsing/validation in 2+ places
- Counterexamples:
  - boundary layers that immediately map to domain types
- Refactorings:
  - newtypes/value objects, enums/ADTs, centralise validation

### Feature Envy
- Heuristics:
  - method calls foreign type members more than its own (foreign_calls > self_calls)
- Counterexamples:
  - formatter/serialiser/adapters whose role is to read and transform
- Refactorings:
  - move method, tell-don't-ask, add behaviour to data owner

### Message Chains
- Heuristics:
  - access chain length >= 3 OR repeated chains across call sites
- Counterexamples:
  - fluent builders intentionally designed for chaining
- Refactorings:
  - hide delegate, introduce facade/query method

### Dead Code
- Heuristics:
  - unused symbol (compiler/linter/call graph), unreachable branch
- Counterexamples:
  - framework hooks, reflection/plugin entry points, exported APIs
- Refactorings:
  - remove, after proving unused and tests pass

### Swallowed / Generic Errors
- Heuristics:
  - ignored fallible results; catch-all without logging/metrics or without context
  - mapping many errors to "unknown"
- Counterexamples:
  - explicit best-effort operations with safe fallback and observability
- Refactorings:
  - propagate with context, typed errors, centralise mapping at boundaries

### Mystery Guest (tests)
- Heuristics:
  - unit tests read env/fs/network/time implicitly; shared mutable fixtures
- Counterexamples:
  - explicit integration tests with clear naming and harness
- Refactorings:
  - explicit fixtures/builders, dependency injection, hermetic harness

## When you need more
If a smell is not covered here, or detection is ambiguous, consult:
- code-smells-expanded.md
- language-notes-rust.md / language-notes-elm.md (if present)
