# code-smells-expanded.md

Purpose: extended catalogue of code smells for refactoring agents. Use when detection is ambiguous, when a smell is not in `code-smells.md`, or when language-specific nuance matters.

This file is *not* intended to be always loaded into context. Prefer `code-smells.md` for routine reviews.

---

## Shared protocol (same as compact)
For each smell reported, output:
- Smell:
- Location: file + symbol
- Evidence: 2+ concrete signals
- Confidence: High|Medium|Low
- Risk: Low|Medium|High
- Suggested refactorings (1-3):
- Counterexample check: why this is NOT a false positive

General rules:
1. Small diffs, one smell per change-set.
2. Preserve behaviour, add/strengthen tests when needed.
3. Avoid refactoring across public API boundaries unless instructed.
4. If Confidence is Low or Risk is High: propose only.
5. Never remove code unless you can prove it is unused.

Thresholds must be tuned per repo and language. Prefer multi-signal detection over LOC-only triggers.

---

## Bloaters

### Long Method
- Signals: high branching, deep nesting, many locals, mixed responsibilities, difficult naming, repeated inline chunks
- Detection heuristics:
  - `LOC > 40` AND (`cyclomatic_complexity > 10` OR `nesting_depth > 3`)
  - `num_local_vars > 12` OR `num_params > 5` with complex branching
  - multiple distinct “responsibility clusters” (identifiers reference unrelated domain concepts)
- Counterexamples:
  - Straight-line mapping/serialisation with low complexity
  - Adapter/boundary glue with clear naming and strong tests
  - Generated code
- Refactorings:
  - Extract Method, Introduce Guard Clauses, Decompose by cases, Extract Variable (for clarity)
- Risk notes:
  - Medium if private behaviour relied upon by subtle side effects; increase tests first

### Long Class / Long Type / Long Module
- Signals: too many public members, low cohesion, multiple reasons to change
- Detection heuristics:
  - `LOC > 500` OR `public_members > 20` OR `methods > 30`
  - Low cohesion proxy: methods touch disjoint subsets of fields
  - Commit history proxy: file changed in unrelated features (topic clustering)
- Counterexamples:
  - Composition roots, wiring modules, DI containers
  - Generated clients/bindings
- Refactorings:
  - Extract Class/Module, Split Responsibility, Facade + internal modules, Extract Subtype (when justified)

### Long Parameter List
- Signals: many params, repeated groups, multiple booleans/options, poor call-site readability
- Detection heuristics:
  - `arity > 5` OR `num_bool_params >= 2`
  - call sites pass many literals (`""`, `0`, `true`) without names
  - parameter groups recur across 3+ functions (overlaps with Data Clumps)
- Counterexamples:
  - Small internal helper with stable call sites and strong types
  - Named arguments used consistently (less severe)
- Refactorings:
  - Introduce Parameter Object (struct/record), Builder/config, Replace booleans with enum/ADT, Split function

### Data Clumps
- Signals: same fields travel together across functions/types/modules
- Detection heuristics:
  - Repeated parameter subsets across `>= 3` functions/types (set similarity)
  - Duplicate tuple/record shapes with same field names/types
- Counterexamples:
  - DTOs at boundaries where shape is dictated by external contract
  - Stable identity pairs used pervasively by convention (documented)
- Refactorings:
  - Extract Value Object, Parameter Object, Encapsulate collection, Move behaviour to new type

### Primitive Obsession
- Signals: IDs/units/states as primitives, repeated parsing/validation, magic constants
- Detection heuristics:
  - Same primitive used for multiple semantic roles (e.g., `String` for different IDs)
  - Repeated parsing/validation logic in 2+ places
  - Comparisons to magic literals representing states
- Counterexamples:
  - Boundary layers (HTTP/DB) that map immediately into domain types
  - Performance-proven hot path where wrappers harm throughput (must cite evidence)
- Refactorings:
  - Newtypes/value objects, enums/ADTs, centralise parsing/validation, Replace Magic Numbers with named constants

---

## Complexity and Readability

### Deep Nesting
- Signals: nested conditionals/matches, hard control flow, poor error paths
- Detection heuristics:
  - `nesting_depth > 3` (tune per language)
  - nested blocks with repeated else/err handling
- Counterexamples:
  - Parser/visitor code reflecting grammar, well tested
  - Exhaustive match with small arms and clear naming
- Refactorings:
  - Guard clauses, Extract Method, Flatten control flow, Replace nested conditionals with early returns

### High Cyclomatic Complexity
- Signals: many branches, hard testing, fragile modifications
- Detection heuristics:
  - `cyclomatic_complexity > 15` OR `branches > 20`
  - many boolean operators in conditions
- Counterexamples:
  - Dispatcher delegating to small handlers
  - Generated decision tables
- Refactorings:
  - Decompose by case, Replace conditional with polymorphism/data-driven dispatch, Extract predicates

### Boolean Blindness
- Signals: unclear meaning of boolean params/fields, flags alter behaviour
- Detection heuristics:
  - `num_bool_params >= 2` OR boolean fields used in multiple branches
  - call sites pass boolean literals frequently
- Counterexamples:
  - Single obvious boolean (`is_dry_run`) with tests and consistent usage
- Refactorings:
  - Replace booleans with enum/ADT, Split function, Introduce option type

### Misleading / Vague Names
- Signals: names don’t match behaviour, generic tokens, “get” methods with side effects
- Detection heuristics:
  - low-information tokens in identifiers (`tmp`, `misc`, `data`, `util`) outside true utility modules
  - side effects detected (writes/mutates/I/O) but name suggests purity
- Counterexamples:
  - Ubiquitous language genuinely uses those terms (documented)
  - Public API names with external consumers (high risk)
- Refactorings:
  - Rename symbol, Extract intention-revealing methods, Make side effects explicit

### Large / Leaky Abstraction
- Signals: abstraction too wide, “kitchen sink” interfaces/traits/modules
- Detection heuristics:
  - Interfaces/traits with many methods (`> 10`) used partially by most implementers
  - Many implementers use default methods or panic/unimplemented
- Counterexamples:
  - Framework-mandated interfaces
  - Explicit façade intended to unify many operations for a single consumer
- Refactorings:
  - Split interface/trait, Introduce smaller ports, Compose multiple traits, Extract module boundaries

---

## Duplication and Dispensables

### Duplicate Code
- Signals: copy-paste, parallel fixes
- Detection heuristics:
  - Token/AST similarity above threshold across 2+ regions
  - Repeated call sequences with minor literal differences
- Counterexamples:
  - Intentional divergence with tests or documented rationale
- Refactorings:
  - Extract helper, Parameterise differences, Consolidate duplicate conditional fragments

### Dead Code
- Signals: unused exports, unreachable branches, unused params/fields
- Detection heuristics:
  - Unreferenced symbol via compiler/linter/call graph
  - Unreachable patterns/branches, feature flag always false
- Counterexamples:
  - Framework hooks, reflection/plugin entry points, exported APIs
- Refactorings:
  - Remove dead code, remove unused parameter, simplify branches (ensure tests)

### Speculative Generality
- Signals: unused abstraction, parameters never varied, scaffolding for “future”
- Detection heuristics:
  - Trait/interface with single impl and no evidence of imminent extension
  - Parameter always passed constant across call sites
- Counterexamples:
  - Public extension points with documented use cases
  - Active roadmap item with linked work
- Refactorings:
  - Inline, Collapse hierarchy, Remove parameter, Simplify API surface

### Over-commenting (compensating comments)
- Signals: comments explain what code does, duplicative comments
- Detection heuristics:
  - Comments restate nearby code or names
  - High comment density where naming is weak
- Counterexamples:
  - “Why” comments, invariants, protocol references, safety notes
- Refactorings:
  - Rename, Extract method, Introduce assertions/invariants, keep “why” comments

---

## Coupling and Encapsulation

### Feature Envy
- Signals: method uses other type more than its own, too many getters
- Detection heuristics:
  - `foreign_calls > self_calls` OR many accesses to foreign fields
- Counterexamples:
  - Formatters/serialisers/adapters
- Refactorings:
  - Move method, Tell-don’t-ask, Introduce behaviour on the data owner

### Message Chains
- Signals: long call chains, leaking internal structure
- Detection heuristics:
  - Chain length `>= 3` OR repeated chains across call sites
- Counterexamples:
  - Fluent builders intentionally designed for chaining
  - Small immutable transformation chains with tests
- Refactorings:
  - Hide delegate, Introduce facade/query method, Cache intermediate (if repeated)

### Inappropriate Intimacy
- Signals: tight coupling, knowledge of internals, friend-like access
- Detection heuristics:
  - Frequent access to non-public members (where language allows)
  - Cross-module types touching each other’s internals repeatedly
- Counterexamples:
  - Deliberate “friend module” with clear boundary and tests (rare)
- Refactorings:
  - Encapsulate fields, Move methods/fields, Introduce boundary interface/port

### Middle Man
- Signals: pass-through delegation without value
- Detection heuristics:
  - High ratio of one-line delegations to real logic
- Counterexamples:
  - Anti-corruption layer translating types/errors
  - Facade stabilising API surface
- Refactorings:
  - Remove/inline, or enrich layer with translation/validation if it is needed

### Global State / Hidden Dependencies
- Signals: functions depend on hidden singletons/config, hard to test
- Detection heuristics:
  - direct reads of global mutable state/config within core logic
  - implicit time/randomness/environment access
- Counterexamples:
  - Composition root initialisation
- Refactorings:
  - Dependency injection (constructor/parameter), explicit context object, boundary adapters

---

## Change Preventers

### Divergent Change
- Signals: one module changes for multiple unrelated reasons
- Detection heuristics:
  - file touched across many unrelated feature areas (if history available)
  - low cohesion, multiple dependency clusters
- Counterexamples:
  - Wiring/composition modules
- Refactorings:
  - Extract module by responsibility, re-align boundaries, introduce stable façade

### Shotgun Surgery
- Signals: one change requires edits across many files
- Detection heuristics:
  - repeated patterned edits across modules for single feature
  - many consumers depend on a small internal detail
- Counterexamples:
  - Legitimate cross-cutting change (rename public API, dependency upgrade)
- Refactorings:
  - Move responsibility behind a stable interface, centralise mapping/logic, reduce fan-out

### Parallel Hierarchies (OOP)
- Signals: changes mirrored across sibling hierarchies
- Detection heuristics:
  - parallel naming patterns across two trees
  - adding one subtype requires adding a parallel subtype elsewhere
- Counterexamples:
  - Code generation outputs
- Refactorings:
  - Collapse hierarchy, prefer composition, data-driven dispatch

---

## Data and State

### Data Class (contextual)
- Signals: only fields/getters, domain rules elsewhere, feature envy around it
- Detection heuristics:
  - type has mostly accessors; “service” types perform all domain rules on it
  - repeated validations/transformations on same fields in multiple places
- Counterexamples:
  - DTOs at boundaries
  - Functional style where data and functions are separated but well organised
- Refactorings:
  - Move behaviour closer to data, introduce invariants/value objects, encapsulate validation

### Mutable Shared State
- Signals: state mutated by many methods, ordering bugs, concurrency hazards
- Detection heuristics:
  - `write_sites > 3` on key fields
  - mutation spans layers (domain + infra) or module boundaries
- Counterexamples:
  - Localised caches with clear ownership and concurrency control
- Refactorings:
  - Encapsulate state, narrow mutability, introduce immutable boundary, state machine/ADT

### Magic Values
- Signals: literals encode business meaning (statuses, thresholds, special cases)
- Detection heuristics:
  - comparisons to repeated literals across codebase
  - repeated “special case” constants (`-1`, `"UNKNOWN"`, etc.)
- Counterexamples:
  - True constants (math), well-known protocol values with citations nearby
- Refactorings:
  - Replace Magic Number/String with named constant, enum/ADT, centralise policy

---

## Error Handling (high leverage)

### Swallowed / Generic Errors
- Signals: ignored results, catch-all without action, lossy error strings
- Detection heuristics:
  - dropping `Result`/`Option` without handling
  - catch-all handlers without logging/metrics or without context propagation
  - mapping all errors to one “unknown” category
- Counterexamples:
  - Explicit best-effort operations with safe fallback and observability
- Refactorings:
  - Propagate with context, typed errors, consistent mapping at boundaries

### Inconsistent Error Mapping
- Signals: same errors mapped differently, duplicated mapping logic
- Detection heuristics:
  - multiple divergent mappers for same error type
  - inconsistent status codes/messages for same failure category
- Counterexamples:
  - Different consumer contracts (proved by spec/tests)
- Refactorings:
  - Centralise mapping, standardise error taxonomy, introduce shared error helpers

---

## Tests

### Mystery Guest
- Signals: external state, unclear setup, implicit dependencies
- Detection heuristics:
  - unit tests read env/fs/network/time implicitly
  - shared mutable fixtures across tests
- Counterexamples:
  - integration tests with explicit harness and naming
- Refactorings:
  - Explicit fixtures/builders, dependency injection, hermetic harness, stable clocks/randomness

### Assertion Roulette
- Signals: many assertions, unclear failure cause
- Detection heuristics:
  - high assert count without messages; multiple unrelated concerns
- Counterexamples:
  - property tests with good failure reporting
- Refactorings:
  - Split test, add messages, focus on one behaviour

### Fragile Test
- Signals: breaks on refactors, tests structure not behaviour
- Detection heuristics:
  - asserts on internal call order, heavy mocking of internals
  - snapshots include unstable fields without normalisation
- Counterexamples:
  - contract tests where interactions are the contract
- Refactorings:
  - Assert outcomes, reduce over-mocking, stabilise snapshots, test at boundaries

### Eager Test
- Signals: covers too many behaviours in one test
- Detection heuristics:
  - multiple arrange/act phases; multiple scenarios in one test
- Counterexamples:
  - intentional end-to-end “journey” test with clear naming
- Refactorings:
  - Split tests, extract builders/helpers, Arrange-Act-Assert clarity

### Obscure Test
- Signals: unclear intent, dense setup, magic constants
- Detection heuristics:
  - large setup with no helper/builder; low signal-to-noise
- Counterexamples:
  - golden master tests with encapsulated setup and clear purpose
- Refactorings:
  - Rename test, builders, extract helpers, reduce noise

---

## Language notes (quick)

### Rust
- Prefer newtypes/enums to avoid primitive obsession and boolean blindness.
- Reduce cloning in refactors; do not introduce unnecessary allocations.
- Watch trait surface area (avoid “kitchen sink” traits), split traits by capability.
- Treat `unsafe` blocks as high risk; refactor around them carefully.

### Elm
- Prefer small pure functions and ADTs for state.
- Avoid “mega update” branches by factoring messages and submodules.
- Data-only records are often fine; flag anemic models only when domain rules are scattered.

---

## When to consult this file
Consult this file when:
- a smell is not in `code-smells.md`,
- detection is ambiguous,
- you need additional refactoring options or language nuance,
- you are asked to propose refactorings without applying them.
