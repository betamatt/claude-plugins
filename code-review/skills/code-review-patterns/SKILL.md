---
name: Code Review Patterns
description: This skill should be used when the user asks about "code review best practices", "how to review code", "review methodology", "code review framework", "impact prioritization", "root cause analysis", or needs guidance on systematic code review approaches and output templates.
version: 0.1.0
---

# Code Review Patterns

A language-agnostic framework for conducting comprehensive, context-aware code reviews that provide actionable feedback with real-world impact prioritization.

## Core Philosophy

Effective code reviews go beyond surface-level issues to understand root causes and systemic patterns. Focus on providing deep, actionable feedback that considers business context, not just technical correctness.

**Key principles:**
- Understand project context and conventions before reviewing
- Provide root cause analysis, not just symptoms
- Include working solutions with every issue
- Prioritize by real-world impact
- Adapt to the language and framework of the codebase

## Pre-Review Context Gathering

Before reviewing, establish context from the project itself:

1. **Read project documentation** - CLAUDE.md, README, CONTRIBUTING, ARCHITECTURE docs
2. **Detect conventions** - Linting configs, formatting rules, existing patterns
3. **Understand structure** - Directory layout, module organization, naming conventions
4. **Identify testing patterns** - Test framework, assertion style, coverage expectations
5. **Check language/framework** - Adapt review criteria to the stack

The codebase itself defines what "good" looks like - discover and apply those standards.

## Root Cause Analysis Framework

For every issue, provide three levels of analysis:

**Level 1 - What**: The immediate issue observed
**Level 2 - Why**: Root cause analysis explaining why this happens
**Level 3 - How**: Specific, actionable solution with working code

This ensures issues are fully understood and solutions address underlying problems, not just symptoms.

## Impact-Based Prioritization

Classify every issue by real-world impact:

| Priority | Label | Criteria | Action |
|----------|-------|----------|--------|
| CRITICAL | Red | Security vulnerabilities, data loss risks, privacy violations, production crashes | Fix immediately |
| HIGH | Orange | Performance in hot paths, resource leaks, broken error handling, missing validation | Fix before merge |
| MEDIUM | Yellow | Maintainability issues, inconsistent patterns, missing tests, tech debt in active areas | Fix soon |
| LOW | Green | Style inconsistencies, minor optimizations, documentation gaps | Fix when convenient |

### Prioritization Factors

- **User-facing code** → Higher priority than internal utilities
- **Security-sensitive paths** (auth, payments, PII) → Highest priority
- **Frequently changed files** → Higher priority (high churn = high impact)
- **Hot paths** (high traffic) → Performance issues more critical

## Six Review Aspects

Comprehensive reviews cover six specialized aspects:

1. **Architecture & Design** - Module organization, separation of concerns, design patterns, dependency direction
2. **Code Quality** - Readability, naming, complexity, DRY principles, cognitive load
3. **Security & Dependencies** - Vulnerabilities, auth, input validation, supply chain
4. **Performance & Scalability** - Algorithm complexity, resource usage, async patterns, caching
5. **Testing Quality** - Meaningful assertions, isolation, edge cases, maintainability
6. **Documentation & API** - Self-documenting code, API docs, breaking changes

For detailed guidance on each aspect, see `references/review-aspects.md`.

## Cross-File Intelligence

Comprehensive review requires understanding relationships:

- **Component → Tests**: Is test coverage adequate?
- **Interface → Implementations**: Are all implementations consistent?
- **Config → Usage**: Do usage patterns align with configuration?
- **Fix → Call sites**: Are all callers handled?
- **API change → Documentation**: Is documentation updated?

Find related files before concluding a review is complete.

## Review Intelligence Layers

Apply five layers of analysis:

1. **Syntax & Style** - Follows project's linting/formatting rules
2. **Patterns & Practices** - Uses established patterns, avoids anti-patterns
3. **Architectural Alignment** - Code in correct layer, proper abstraction level
4. **Business Logic Coherence** - Logic matches requirements, edge cases handled
5. **Evolution & Maintenance** - How code ages, testability, extensibility

## Solution-Oriented Feedback

Never just identify problems - always show the fix. A quality issue report includes:

1. **Issue title** with file location
2. **Impact** - Real-world consequence
3. **Root cause** - Why this happens
4. **Solution** - Working code in the project's language/style
5. **Alternatives** (optional) - Other valid approaches

Adapt solutions to match the codebase's existing patterns and conventions.

## Review Output Template

Structure feedback consistently:

```markdown
# Code Review: [Scope]

## Review Metrics
- **Files Reviewed**: X
- **Critical Issues**: X
- **High Priority**: X
- **Medium Priority**: X
- **Suggestions**: X

## Executive Summary
[2-3 sentences summarizing the most important findings]

## CRITICAL Issues (Must Fix)
[Issues with root cause analysis and working solutions]

## HIGH Priority (Fix Before Merge)
[Issues with root cause analysis and working solutions]

## MEDIUM Priority (Fix Soon)
[Issues with root cause analysis and working solutions]

## LOW Priority (Opportunities)
[Suggestions and minor improvements]

## Strengths
[What's done well, patterns worth replicating]

## Proactive Suggestions
[Opportunities beyond identified issues]

## Systemic Patterns
[Issues appearing multiple times - candidates for team discussion]
```

## Additional Resources

### Reference Files

For detailed patterns per review aspect, consult:
- **`references/review-aspects.md`** - Deep dive into each of the 6 review aspects

### Success Criteria

A quality review should:
- Understand project context and conventions first
- Adapt to the language and framework in use
- Provide root cause analysis, not just symptoms
- Include working solutions in the project's style
- Prioritize by real-world impact
- Consider evolution and maintenance
- Reference existing patterns in the codebase
