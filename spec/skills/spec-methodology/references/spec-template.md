# Specification Template

The 17-section template for comprehensive software specifications.

## Template Structure

```markdown
# [Feature/Bugfix Title]

## 1. Status
Draft | Under Review | Approved | Implemented

## 2. Authors
- [Name] - [Date]

## 3. Overview
Brief description and purpose of this feature/bugfix.

## 4. Background/Problem Statement
Why this feature is needed or what problem it solves.
Include user pain points, business drivers, or technical debt.

## 5. Goals
What we aim to achieve:
- [ ] Goal 1
- [ ] Goal 2
- [ ] Goal 3

## 6. Non-Goals
What is explicitly out of scope:
- Non-goal 1
- Non-goal 2

## 7. Technical Dependencies
- Library/Framework: version requirement
- External service: API version
- Links to relevant documentation

## 8. Detailed Design

### Architecture Changes
Describe any architectural changes required.

### Implementation Approach
Step-by-step implementation strategy.

### Code Structure
```
src/
├── new-module/
│   ├── index.ts
│   └── helpers.ts
└── existing-module/
    └── changes.ts
```

### API Changes
Document any API additions/modifications.

### Data Model Changes
Schema changes, migrations needed.

## 9. User Experience
How users will interact with this feature.
Include user flows, UI mockups if applicable.

## 10. Testing Strategy

### Unit Tests
- Test case 1: validates X behavior
- Test case 2: validates Y edge case

### Integration Tests
- Integration with service A
- Integration with service B

### E2E Tests (if needed)
- User flow test 1
- User flow test 2

### Mocking Strategies
How to mock external dependencies.

## 11. Performance Considerations
- Expected impact on performance
- Mitigation strategies
- Benchmarks to establish

## 12. Security Considerations
- Security implications
- Required safeguards
- Threat model (if applicable)

## 13. Documentation
What documentation needs to be created/updated:
- [ ] API documentation
- [ ] User guide
- [ ] Code comments
- [ ] README updates

## 14. Implementation Phases

### Phase 1: MVP/Core Functionality
- Task 1
- Task 2

### Phase 2: Enhanced Features (if applicable)
- Task 3
- Task 4

### Phase 3: Polish and Optimization (if applicable)
- Task 5
- Task 6

## 15. Open Questions
- [ ] Question 1?
- [ ] Question 2?

## 16. References
- [Related Issue](link)
- [Library Documentation](link)
- [Design Pattern Reference](link)

## 17. Appendix (optional)
Additional diagrams, code examples, or supporting material.
```

## Section Guidelines

### Problem Statement (Section 4)

A good problem statement:

- Describes the current pain point clearly
- Quantifies impact when possible
- Explains why existing solutions are insufficient
- Avoids prescribing solutions

**Good example:**
> Users currently wait 15+ seconds for dashboard loads because we fetch all data synchronously. This causes 23% of users to abandon the page before it loads.

**Bad example:**
> We need to add caching to make the dashboard faster.

### Goals vs Non-Goals (Sections 5-6)

Goals should be:

- Specific and measurable
- Tied to user/business value
- Achievable within the scope

Non-goals clarify boundaries:

- Prevent scope creep
- Set expectations
- Document intentional omissions

### Detailed Design (Section 8)

Include enough detail that someone unfamiliar with the codebase could implement:

- File paths and module structure
- Function signatures
- Data flow diagrams
- Configuration examples
- Error handling approach

### Testing Strategy (Section 10)

Each test should have a purpose comment:

```typescript
// Verifies that expired tokens are rejected even if signature is valid
test('rejects expired JWT tokens', () => { ... })
```

Avoid tests that always pass:

```typescript
// BAD: This test passes even if validation is broken
test('validates input', () => {
  expect(validate({})).toBeDefined(); // Always true
})

// GOOD: This test fails if validation breaks
test('rejects empty input with specific error', () => {
  expect(() => validate({})).toThrow('Input required');
})
```

## Naming Conventions

- Features: `feat-{kebab-case-name}.md`
- Bugfixes: `fix-{issue-number}-{brief-description}.md`

Examples:

- `feat-user-authentication.md`
- `feat-api-rate-limiting.md`
- `fix-123-login-timeout.md`
- `fix-456-memory-leak-dashboard.md`
