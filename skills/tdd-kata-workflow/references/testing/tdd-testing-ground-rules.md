# TDD Testing Ground Rules (Agent and Human Guide)

Purpose: write tests that support fast feedback, safe refactoring, and clear intent. These are guidelines, not laws. When a rule conflicts with clarity or safety, document the trade-off.

---

## 1) Decide what you are testing

### Prefer behaviour over implementation
- Test externally observable outcomes: return values, state changes at boundaries, emitted events, persisted records, sent requests.
- Avoid asserting internal call order, private helper usage, or exact intermediate values unless that is the contract.

When it is acceptable to test implementation details:
- Performance constraints (e.g., caching is required, query count is a contract).
- Critical interactions are the contract (e.g., contract tests for a port, protocol compliance).
- Bug regression where the failure mode is tightly tied to a specific internal decision.

### Choose the smallest meaningful scope
Aim for the test that gives confidence with the least setup.

- Pure logic: unit test a function/module.
- Domain behaviour with dependencies: unit test the domain + fake ports.
- Integration across boundaries (DB, HTTP, message broker): fewer tests, higher value, slower feedback.
- End-to-end: very few, cover core user journeys.

---

## 2) Which kind of test to write

### Use a simple testing pyramid as a default
- Many: fast deterministic tests (pure logic, domain with fakes).
- Some: integration tests per boundary (DB mapping, HTTP client/server, message publishing).
- Few: end-to-end tests for critical flows.

This is a default, not a rule. If the system is mostly glue code, integration tests may be the best value.

### Map test type to uncertainty
Write tests where you are least certain:
- Complex branching or edge cases: unit tests.
- Boundary translations (HTTP/DB/event): integration tests.
- Risky refactor: characterisation tests before changing code.

---

## 3) Ground rules for writing a good test

### Make the test readable first
- Use a “speaking name” that describes behaviour and scenario.
  - Example format: `when_<context>_then_<outcome>` or `should_<outcome>_when_<context>`.
- Keep one behaviour per test; split if you find “and”.

### Keep the structure consistent
Prefer Arrange / Act / Assert (AAA).
- Arrange: build inputs and dependencies.
- Act: call one unit of behaviour.
- Assert: check the relevant outcomes.

### Assert outcomes, not steps
Prefer:
- Result values
- Persisted state (via a test DB or fake repository)
- Published messages (captured by a fake bus)
- Sent requests (captured by a fake HTTP client)
- Logged/metric’d signals only when they are required

Avoid:
- Asserting every intermediate variable
- Asserting internal helper calls
- Asserting exact formatting unless formatting is the product

### Use the minimum assertions that prove the behaviour
- Too many assertions make failures hard to diagnose.
- Too few assertions allow false positives.

A good pattern:
- Assert the *one* primary outcome, plus 1–2 key properties that define correctness.

### Prefer deterministic tests
- No real time: inject a controllable clock.
- No randomness: inject a seeded RNG.
- No network/filesystem by default: inject ports, use fakes.
- Avoid sleeps; prefer event synchronisation or explicit hooks.

---

## 4) Handling side effects (dependencies and ports)

### Inject controllable dependencies
If the behaviour depends on side effects, depend on interfaces/ports:
- Clock, UUID generator, RNG
- Repositories (DB)
- HTTP clients
- Message bus/event publisher
- File system
- External services

Testing approach:
- Use fakes/spies for ports in unit tests to capture interactions and outputs.
- Use real implementations in integration tests, but keep them hermetic (local DB, in-memory broker where possible).

### Verify interactions only at boundaries
It is fine to assert “published event X” or “sent request Y” if:
- the interaction is the externally observable behaviour, or
- it is a port contract you must honour.

Prefer asserting *what* is sent over *how* it is produced.

---

## 5) Data and fixtures

### Keep test data meaningful
- Use domain-relevant values rather than `foo`, `bar`.
- Choose values that communicate intent (e.g., `inactive_policy`, `expired_quote`).

### Prefer builders over massive inline fixtures
- Use object builders / test data builders to keep setup short.
- Avoid sharing mutable global fixtures.
- Prefer explicit per-test setup to avoid mystery guests.

### Reduce noise
- Only include fields that matter to the behaviour under test.
- Use defaults for the rest.

---

## 6) Coverage of behaviour (what to look for)

Write tests for:
- Happy path (one representative case)
- Important edge cases:
  - boundaries (min/max, empty, missing)
  - invalid inputs and error mapping
  - idempotency and retries (when relevant)
  - ordering and concurrency assumptions (when relevant)
- Invariants:
  - “illegal states unrepresentable” is ideal, but tests can enforce invariants too

Do not try to test every possible input combination. Prefer representative partitions.

---

## 7) Red, Green, Refactor hygiene

### Red
- A failing test should fail for the right reason.
- Avoid writing a test that can pass without the intended behaviour.

### Green
- Make it pass with the simplest correct change.
- Avoid over-generalising too early.

### Refactor
- Refactor code and also tests: tests are first-class citizens, so treat them with equal care.
- Keep tests readable and maintainable.

---

## 8) Common test smells to avoid (quick list)
- Mystery guest: hidden env/fs/network/time dependencies.
- Assertion roulette: many asserts, unclear failures.
- Fragile tests: test internal call order or private structure.
- Eager tests: multiple behaviours in one test.
- Obscure tests: unclear naming, huge setup, magic constants.
- Over-mocking: mocks everywhere, low confidence in refactoring.

---

## 9) Exception handling and contracts

### Errors are behaviour
- If a function can fail, test:
  - error type/category
  - key context (not necessarily full message)
  - mapping at the boundary (HTTP status, error code, etc.)

### Contract tests (when relevant)
For a port boundary:
- Define a small suite of tests that any adapter must satisfy.
- Keep contracts stable, version them if necessary.

---

## 10) Agent-specific operating rules (optional)
If used by an automated agent:
- Prefer adding tests over modifying existing ones unless the existing test is clearly incorrect.
- Do not rewrite large test suites while doing production refactors.
- If test intent is unclear, propose a rename or small rewrite, do not “optimise” aggressively.
- If integration setup is unknown or flaky, propose a hermetic alternative.
