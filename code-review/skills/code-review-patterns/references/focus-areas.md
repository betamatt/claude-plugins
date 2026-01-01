# Code Review Focus Areas

This is the canonical reference for the six code review focus areas. All components should reference this file rather than duplicating definitions.

---

## 1. Architecture & Design

**Purpose**: Evaluate structural integrity, module organization, and design pattern application.

**Key Questions**:
- Does the code follow established architectural patterns?
- Is there proper separation of concerns between layers?
- Are dependencies flowing in the correct direction?
- Is the code in the appropriate module/directory?

**What to Look For**:
- Layer violations (business logic in controllers, queries in views)
- Circular dependencies between modules
- Tight coupling to implementations instead of interfaces
- Missing or inappropriate design patterns
- Code in wrong architectural layer

**Priority Factors**:
- Core domain code → Higher priority
- Shared infrastructure → Higher priority (affects many consumers)
- Isolated utilities → Lower priority

---

## 2. Code Quality

**Purpose**: Assess readability, maintainability, and adherence to clean code principles.

**Key Questions**:
- Is the code self-documenting through clear naming?
- Are functions/methods appropriately sized?
- Is there unnecessary duplication?
- Can a new developer understand this quickly?

**What to Look For**:
- Vague names (data, info, handler, temp, result)
- Functions doing too many things
- Deep nesting (more than 3 levels)
- Copy-pasted code blocks
- Magic numbers/strings without context
- Complex conditionals that could be simplified

**Priority Factors**:
- Frequently modified files → Higher priority
- Public APIs → Higher priority
- Internal utilities → Lower priority

---

## 3. Security & Dependencies

**Purpose**: Identify vulnerabilities, authentication issues, and supply chain risks.

**Key Questions**:
- Are there potential injection vulnerabilities?
- Is authentication/authorization properly implemented?
- Are secrets hardcoded or properly managed?
- Are dependencies up-to-date and secure?

**What to Look For**:
- SQL/NoSQL injection (string concatenation in queries)
- XSS vulnerabilities (unsanitized output)
- Command injection (user input in shell commands)
- Hardcoded API keys, passwords, or tokens
- Missing authorization checks
- Known vulnerabilities in dependencies

**Priority Factors**:
- User-facing endpoints → CRITICAL
- Authentication/payment flows → CRITICAL
- Internal services → HIGH
- Development tools → MEDIUM

---

## 4. Performance & Scalability

**Purpose**: Evaluate algorithm efficiency, resource usage, and load handling.

**Key Questions**:
- Are there inefficient algorithms (O(n²) or worse)?
- Are database queries optimized?
- Are async operations properly parallelized?
- Will this scale with increased load?

**What to Look For**:
- Nested loops on large datasets
- N+1 query patterns
- Sequential operations that could be parallel
- Missing pagination for large result sets
- Unbounded caches or queues
- Resource leaks (connections, listeners, memory)

**Priority Factors**:
- Hot paths (high-traffic code) → CRITICAL
- User-facing latency → HIGH
- Background jobs → MEDIUM
- One-time scripts → LOW

---

## 5. Testing Quality

**Purpose**: Assess test value, coverage, and maintainability.

**Key Questions**:
- Do tests verify behavior, not just run without error?
- Are tests isolated and independent?
- Are edge cases and error paths covered?
- Do tests document expected behavior?

**What to Look For**:
- Tests without meaningful assertions
- Tests depending on execution order
- Shared mutable state between tests
- Missing edge case tests (null, empty, boundary)
- Tests tightly coupled to implementation details
- Flaky tests (time-dependent, external dependencies)

**Priority Factors**:
- Critical business logic → CRITICAL
- Integration points → HIGH
- UI components → MEDIUM
- Internal utilities → LOW

---

## 6. Documentation & API

**Purpose**: Evaluate developer experience and maintainability through documentation.

**Key Questions**:
- Is the code self-documenting?
- Are public APIs properly documented?
- Are breaking changes clearly communicated?
- Can new developers onboard quickly?

**What to Look For**:
- Complex logic without explanatory comments
- Public functions without parameter documentation
- Missing return value descriptions
- Undocumented error conditions
- Breaking changes without migration guides
- Outdated or missing README

**Priority Factors**:
- Public APIs → CRITICAL
- Breaking changes → CRITICAL
- Internal APIs → MEDIUM
- Implementation details → LOW

---

## Impact Prioritization Matrix

| Priority | Criteria | Timeline |
|----------|----------|----------|
| CRITICAL | Security vulnerabilities, data loss, crashes | Immediate |
| HIGH | Performance in hot paths, memory leaks, broken error handling | Before merge |
| MEDIUM | Maintainability, inconsistent patterns, missing tests | Next sprint |
| LOW | Style, minor optimizations, doc gaps | Backlog |

## Cross-Cutting Considerations

When reviewing, also consider:
- **Component → Tests**: Is test coverage adequate?
- **Interface → Implementations**: Are all implementations consistent?
- **Config → Usage**: Do usage patterns align with configuration?
- **API change → Documentation**: Is documentation updated?
- **Fix → Call sites**: Are all callers handled?
