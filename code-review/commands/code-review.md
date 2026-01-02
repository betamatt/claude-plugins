---
name: code-review
description: Run comprehensive code review with multiple modes (manual, git changes, focused, or comprehensive)
argument-hint: "[files|--changed|--focus=<area>|--all]"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Task"]
---

Run a comprehensive code review on the specified scope with multiple modes.

## Modes

### 1. **Manual Mode** (Default)
Review specific files, directories, or the entire repository manually.

### 2. **Git Changes Mode** (`--changed`)
Review only files changed since last commit.

### 3. **Focused Mode** (`--focus=<area>`)
Target specific review aspects across the scope.

## Arguments

- **files**: Specific file paths, glob patterns, or directories to review
- **--changed**: Review files changed since last commit (git diff)
- **--focus=<area>**: Focus on a specific review area
- **--all**: Review entire repository (comprehensive mode)

## Focus Areas

Available focus areas (use with --focus):
- `architecture` - Module organization, separation of concerns, design patterns
- `security` - Vulnerabilities, auth issues, secrets, supply chain
- `performance` - Algorithm complexity, N+1 queries, async patterns, memory
- `quality` - Readability, naming, complexity, DRY principles
- `testing` - Assertions, isolation, edge cases, maintainability
- `docs` - README, JSDoc, breaking changes, API documentation

## Process

1. **Determine Scope and Mode**
   - **Manual Mode**: If files/directories specified, review those
   - **Git Changes Mode**: If `--changed`, get files from `git diff --name-only HEAD`
   - **Comprehensive Mode**: If `--all` or no arguments, review entire repository
   - **Focused Mode**: If `--focus` specified, target specific review aspect

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

### Manual Mode
```
/code-review src/auth/                    # Review specific directory
/code-review *.ts                         # Review all TypeScript files
/code-review src/api/user.ts src/models/  # Review specific files
```

### Git Changes Mode
```
/code-review --changed                    # Review all changed files
/code-review --changed --focus=security   # Review security of changes
```

### Comprehensive Mode
```
/code-review --all                        # Review entire repository
/code-review                              # Review entire repository (default)
/code-review --all --focus=performance    # Performance review of entire repo
```

### Focused Mode
```
/code-review --focus=security src/api/    # Security review of API directory
/code-review *.ts --focus=performance      # Performance review of TypeScript files
```
