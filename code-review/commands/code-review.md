---
name: code-review
description: Run comprehensive code review on specified files or recent changes
argument-hint: "[files|--changed|--focus=<area>]"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Task"]
---

Run a comprehensive code review on the specified scope.

## Arguments

- **files**: Specific file paths or glob patterns to review
- **--changed**: Review files changed since last commit (git diff)
- **--focus=<area>**: Focus on a specific review area

## Focus Areas

Available focus areas (use with --focus):
- `architecture` - Module organization, separation of concerns, design patterns
- `security` - Vulnerabilities, auth issues, secrets, supply chain
- `performance` - Algorithm complexity, N+1 queries, async patterns, memory
- `quality` - Readability, naming, complexity, DRY principles
- `testing` - Assertions, isolation, edge cases, maintainability
- `docs` - README, JSDoc, breaking changes, API documentation

## Process

1. **Determine Scope**
   - If files specified, review those files
   - If `--changed`, get files from `git diff --name-only HEAD`
   - If no argument, review files in current directory

2. **Gather Context**
   - Read project documentation (CLAUDE.md, README.md, ARCHITECTURE.md)
   - Detect project conventions from config files
   - Understand existing patterns in the codebase

3. **Execute Review**
   - If `--focus` specified, perform targeted single-aspect review
   - Otherwise, launch 6 code-reviewer agents in parallel covering all aspects:
     1. Architecture & Design
     2. Code Quality
     3. Security & Dependencies
     4. Performance & Scalability
     5. Testing Quality
     6. Documentation & API

4. **Consolidate Results**
   - Merge findings from all review aspects
   - Prioritize by impact (CRITICAL > HIGH > MEDIUM > LOW)
   - Present unified report with actionable solutions

## Output Format

```markdown
# Code Review: [Scope]

## Summary
- Files Reviewed: X
- Critical Issues: X
- High Priority: X
- Medium Priority: X

## Critical Issues
[Issues with root cause analysis and working solutions]

## High Priority
[Issues with root cause analysis and working solutions]

## Medium Priority
[Issues with root cause analysis and working solutions]

## Strengths
[Well-done aspects worth preserving]

## Recommendations
[Proactive improvements beyond issues found]
```

## Examples

```
/code-review src/auth/
/code-review --changed
/code-review --focus=security src/api/
/code-review *.ts --focus=performance
```
