# Code Review Plugin

Comprehensive code review toolkit with a single expert agent that can be launched multiple times in parallel to cover 6 specialized review aspects.

## Architecture

**Single Agent, Multiple Instances**: One `code-reviewer` agent contains all review expertise. For comprehensive reviews, launch 6 instances in parallel, each assigned a different focus area.

## Review Aspects

| Focus Area | What It Checks |
|------------|----------------|
| Architecture & Design | Module organization, separation of concerns, design patterns |
| Code Quality | Readability, naming, complexity, DRY principles |
| Security & Dependencies | Vulnerabilities, auth, secrets, supply chain |
| Performance & Scalability | Algorithm complexity, N+1, async patterns |
| Testing Quality | Assertions, isolation, edge cases |
| Documentation & API | README, JSDoc, breaking changes |

## Components

| Type | Name | Purpose |
|------|------|---------|
| Agent | `code-reviewer` | Single expert agent for all review aspects |
| Skill | `code-review-patterns` | Core methodology, patterns, and reference material |

## Usage

### Comprehensive Review (Parallel)

```
"Do a full code review of this module"
→ Launches 6 code-reviewer instances in parallel, one per aspect
```

### Targeted Review (Single Focus)

```
"Check this for security vulnerabilities"
→ Launches 1 code-reviewer instance focused on security

"Review the architecture of this service"
→ Launches 1 code-reviewer instance focused on architecture
```

### After Code Changes (Proactive)

```
"I've finished the authentication module"
→ May launch security + architecture reviewers automatically
```

## Review Output

Each instance produces structured feedback:

```markdown
## [Focus Area] Review: [Scope]

### Health Assessment
- [Metric]: [Good/Needs Attention/Critical]

### Issues Found

#### [PRIORITY] Issue Title
**File:** `path/to/file.ts:line`
**Problem:** [Description]
**Root Cause:** [Why this happens]
**Solution:** [Working code fix]

### Strengths
### Recommendations
```

## Priority Levels

| Priority | Criteria | Action |
|----------|----------|--------|
| CRITICAL | Security vulnerabilities, data loss | Fix immediately |
| HIGH | Performance issues, memory leaks | Fix before merge |
| MEDIUM | Maintainability, missing tests | Fix soon |
| LOW | Style, minor improvements | Fix when convenient |

## Installation

```bash
claude --plugin-dir /path/to/code-review
```

## Why Single Agent?

- **Less duplication**: One file instead of 6
- **Easier maintenance**: Update once, applies everywhere
- **Same parallelism**: Still runs 6 instances concurrently
- **Shared knowledge**: All instances access the same skill

## License

MIT
