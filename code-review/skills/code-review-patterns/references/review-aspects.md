# Code Review Aspects - Detailed Guide

Language-agnostic guidance for each of the six specialized review aspects. Adapt these patterns to the specific language and framework of the codebase being reviewed.

---

## 1. Architecture & Design Review

Focus on structural integrity, module organization, and design pattern application.

### Key Questions

- Does the code follow established architectural patterns in the codebase?
- Is there proper separation of concerns between layers?
- Are dependencies flowing in the correct direction?
- Is the code in the appropriate module/directory?
- Are abstractions at the right level?

### What to Look For

**Layer Violations**
- Business logic in controllers/handlers/routes
- Database queries in presentation layer
- UI concerns in business logic
- Cross-cutting concerns not properly isolated

**Dependency Issues**
- Circular dependencies between modules
- Tight coupling to implementations instead of interfaces
- Missing dependency injection where patterns exist
- Inappropriate coupling between unrelated modules

**Design Pattern Problems**
- Singleton abuse causing testing difficulties
- Over-engineering with unnecessary patterns
- Missing patterns where they would simplify code
- Inconsistent pattern application across similar code

### Review Process

1. Understand the project's architectural style from docs and structure
2. Check if new code follows established layer boundaries
3. Verify dependencies flow toward stable abstractions
4. Look for coupling that will make changes difficult
5. Identify if code is in the correct module/package

### Issue Format

```
**Issue**: [Description of architectural problem]
**Location**: [File and area]
**Layer Violation**: [Which layers are inappropriately coupled]
**Root Cause**: [Why this coupling exists]
**Impact**: [What becomes difficult - testing, changes, etc.]
**Solution**: [How to restructure, following project patterns]
```

---

## 2. Code Quality Review

Focus on readability, maintainability, and clean code principles.

### Key Questions

- Is the code self-documenting through clear naming?
- Are functions/methods appropriately sized?
- Is there unnecessary duplication?
- Is the complexity reasonable?
- Can a new developer understand this quickly?

### What to Look For

**Naming Problems**
- Vague names (data, info, handler, process, temp, result)
- Inconsistent naming conventions across files
- Non-obvious abbreviations
- Names that don't reflect purpose or behavior

**Complexity Issues**
- Functions doing too many things
- Deep nesting (more than 3 levels)
- Long parameter lists
- Complex conditionals that could be simplified
- High cognitive load to understand

**DRY Violations**
- Copy-pasted code blocks
- Similar logic in multiple places
- Repeated validation or transformation patterns
- Duplicate error handling

**Readability Issues**
- Magic numbers/strings without context
- Clever code that's hard to follow
- Missing or misleading comments
- Inconsistent formatting

### Review Process

1. Read the code as if you're new to the project
2. Note where you have to re-read or think hard
3. Check naming against project conventions
4. Look for repeated patterns that could be extracted
5. Identify functions that do too many things

### Issue Format

```
**Issue**: [What's wrong with the code quality]
**Location**: [File and line range]
**Problem**: [Specific quality issue]
**Cognitive Load**: [Why this is hard to understand]
**Refactoring**: [How to improve, matching project style]
```

---

## 3. Security & Dependencies Review

Focus on vulnerabilities, authentication, and supply chain security.

### Key Questions

- Are there potential injection vulnerabilities?
- Is authentication/authorization properly implemented?
- Are secrets hardcoded or properly managed?
- Are dependencies up-to-date and secure?
- Is input from external sources validated?

### What to Look For

**Injection Vulnerabilities**
- SQL/NoSQL queries built with string concatenation
- User input rendered without sanitization (XSS)
- Shell commands with unsanitized input
- Template injection possibilities
- Path traversal vulnerabilities

**Authentication Issues**
- Missing authorization checks
- Insecure token/session storage
- Weak credential validation
- Session fixation vulnerabilities
- Missing rate limiting on auth endpoints

**Secrets Exposure**
- Hardcoded API keys, passwords, or tokens
- Secrets in client-side code
- Credentials in version control
- Unencrypted sensitive data storage
- Secrets in logs or error messages

**Dependency Issues**
- Known vulnerabilities in dependencies
- Outdated packages with security patches
- Unnecessary dependencies increasing attack surface
- Missing lockfile or integrity checks

### Review Process

1. Identify all external input sources (user input, APIs, files)
2. Trace how external data flows through the code
3. Check for parameterization in database queries
4. Look for hardcoded secrets or credentials
5. Review dependency security status

### Issue Format

```
**Issue**: [Security vulnerability type]
**Location**: [File and line]
**Attack Vector**: [How it can be exploited]
**Impact**: [What an attacker could achieve]
**Severity**: [CRITICAL/HIGH/MEDIUM based on exploitability]
**Secure Fix**: [How to fix using secure patterns]
```

---

## 4. Performance & Scalability Review

Focus on algorithm efficiency, resource usage, and load handling.

### Key Questions

- Are there inefficient algorithms (O(n²) or worse)?
- Are database queries optimized?
- Are async operations properly parallelized?
- Are resources properly managed (memory, connections)?
- Will this scale with increased load?

### What to Look For

**Algorithm Issues**
- Nested loops on potentially large datasets
- Repeated expensive calculations
- Linear searches where indexed lookups exist
- Missing memoization for repeated computations
- Inefficient data structure choices

**Database Performance**
- N+1 query patterns (query per item in loop)
- Missing indexes for common queries
- Loading entire collections into memory
- Missing pagination for large result sets
- Inefficient joins or subqueries

**Async Anti-patterns**
- Sequential operations that could be parallel
- Missing concurrency limits on parallel operations
- Blocking operations in async contexts
- Unhandled async errors

**Resource Issues**
- Event listeners or subscriptions not cleaned up
- Connections not properly pooled or closed
- Unbounded caches or queues
- Large object retention preventing garbage collection

### Review Process

1. Identify hot paths (user-facing, high-traffic code)
2. Look for loops that could grow with data
3. Check database access patterns for N+1
4. Verify async operations are appropriately parallelized
5. Check for resource cleanup in error paths

### Issue Format

```
**Issue**: [Performance problem type]
**Location**: [File and line]
**Complexity**: [Time/space complexity if relevant]
**Impact**: [How this affects users or resources]
**Scale Factor**: [What makes this worse as load increases]
**Optimization**: [How to improve, with expected benefit]
```

---

## 5. Testing Quality Review

Focus on test value, not just coverage metrics.

### Key Questions

- Do tests verify behavior, not just run without error?
- Are tests isolated and independent?
- Are edge cases and error paths covered?
- Are tests maintainable and readable?
- Do tests document expected behavior?

### What to Look For

**Assertion Issues**
- Tests that only check "no error thrown"
- Missing negative test cases
- Incomplete state verification
- Assertions that don't match test description
- Over-reliance on snapshot tests without understanding

**Isolation Problems**
- Tests depending on execution order
- Shared mutable state between tests
- Tests depending on external services without mocking
- Time-dependent tests without proper handling
- Tests that modify global state

**Coverage Gaps**
- Missing edge case tests (empty, null, boundary)
- No error path testing
- Untested integration points
- Missing regression tests for fixed bugs
- Only happy path coverage

**Maintainability Issues**
- Overly complex test setup
- Duplicated test code
- Tests tightly coupled to implementation details
- Magic values without explanation
- Tests that break with valid refactoring

### Review Process

1. Check if tests would catch real bugs
2. Verify tests are independent (can run in any order)
3. Look for missing edge cases and error scenarios
4. Ensure tests document expected behavior
5. Check if tests would survive valid refactoring

### Issue Format

```
**Issue**: [Testing problem type]
**Location**: [Test file and test name]
**Gap**: [What's not being verified]
**Risk**: [What bugs could slip through]
**Better Test**: [How to improve the test]
```

---

## 6. Documentation & API Review

Focus on developer experience and maintainability.

### Key Questions

- Is the code self-documenting?
- Are public APIs properly documented?
- Are breaking changes clearly communicated?
- Can new developers onboard quickly?
- Is documentation accurate and up-to-date?

### What to Look For

**Self-Documentation Issues**
- Complex logic without explanatory comments
- Non-obvious algorithms without explanation
- Business rules embedded without context
- Workarounds without explaining why

**API Documentation Gaps**
- Public functions without parameter documentation
- Missing return value descriptions
- Undocumented error conditions
- No usage examples for complex APIs
- Missing type information

**Breaking Changes**
- API changes without version bump
- Removed functionality without deprecation period
- Changed behavior without migration guide
- Missing changelog entries

**Developer Experience**
- Missing or outdated README
- No setup/installation instructions
- Undocumented configuration options
- Missing troubleshooting guidance

### Review Process

1. Try to understand code without external context
2. Check if public APIs have adequate documentation
3. Look for breaking changes that need communication
4. Verify documentation matches actual behavior
5. Consider onboarding experience for new developers

### Issue Format

```
**Issue**: [Documentation problem type]
**Location**: [File or API]
**Gap**: [What's missing or unclear]
**Impact**: [Developer confusion, integration issues]
**Documentation**: [What should be added]
```

---

## Parallel Review Strategy

For comprehensive coverage, run all six aspects simultaneously:

1. Each review instance focuses on one aspect
2. Each applies the specific checklist above
3. Results consolidate into unified report
4. Cross-cutting issues identified across aspects

This approach ensures:
- Deep expertise applied to each area
- Faster overall review time
- No aspect overlooked
- Consistent analysis framework across aspects
