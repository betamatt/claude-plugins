# Spec Plugin

Specification-driven development workflow for Claude Code with creation, validation, decomposition, and execution phases.

## Features

### Commands

| Command | Description |
|---------|-------------|
| `/spec:create <description>` | Generate comprehensive specification from feature/bugfix description |
| `/spec:validate <spec-file>` | Analyze spec for completeness and detect overengineering |
| `/spec:decompose <spec-file>` | Break spec into actionable tasks with STM/TodoWrite |
| `/spec:execute <spec-file>` | Implement spec with review-fix loops |
| `/spec:implement <spec-file> [--pr]` | End-to-end: validate, decompose, execute with review loops |

### Agents

| Agent | Description |
|-------|-------------|
| `task-executor` | Executes single task with full lifecycle: implement, test, review, fix |
| `issue-fixer` | Fixes code review issues by severity (CRITICAL, IMPORTANT) |

### Skills

- **Specification-Driven Development** - Methodology guidance, best practices, and workflow overview

### Hooks

- **SessionStart** - Detects `specs/` directory and mentions available commands

## Workflow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   CREATE    │────▶│  VALIDATE   │────▶│  DECOMPOSE  │────▶│   EXECUTE   │
│             │     │             │     │             │     │             │
│ First       │     │ WHY/WHAT/   │     │ Task        │     │ Implement   │
│ principles  │     │ HOW check   │     │ breakdown   │     │ Test/Review │
│ analysis    │     │ YAGNI       │     │ STM/Todo    │     │ Fix Loop    │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                                                                   │
                              Or use /spec:implement for all-in-one ◀┘
```

## Installation

### From Marketplace

```bash
claude plugin install spec@betamatt-claude-plugins
```

### Local Development

```bash
claude plugin install ./spec
```

## Usage

### 1. Create a Specification

```bash
/spec:create user authentication with OAuth2
```

This generates a comprehensive spec in `specs/feat-user-authentication.md` with:

- First-principles problem analysis
- 17-section template covering all aspects
- Technical dependencies and design details
- Testing strategy and implementation phases

### 2. Validate the Specification

```bash
/spec:validate specs/feat-user-authentication.md
```

Analyzes for:

- **Completeness**: WHY (intent), WHAT (scope), HOW (implementation)
- **Overengineering**: Applies YAGNI principle aggressively
- **Quality**: Ready/Not Ready assessment with specific gaps

### 3. Decompose into Tasks

```bash
/spec:decompose specs/feat-user-authentication.md
```

Creates:

- Task breakdown document (`specs/feat-user-authentication-tasks.md`)
- Tasks in STM or TodoWrite with full implementation details
- Dependency mapping and parallel execution opportunities

### 4. Execute Implementation

```bash
/spec:execute specs/feat-user-authentication.md
```

Orchestrates:

- Implementation with domain-specific best practices
- Testing and code review cycles
- Atomic commits per completed task

### Alternative: End-to-End Implementation

```bash
/spec:implement specs/feat-user-authentication.md --pr
```

Runs the complete workflow in one command:

1. Validates the spec (stops if not ready)
2. Decomposes into tasks
3. Executes each task with review-fix loops (max 3 iterations)
4. Creates a PR (with `--pr` flag)

The review-fix loop automatically:

- Runs code review after implementation
- Fixes CRITICAL and IMPORTANT issues
- Re-reviews until passing or escalates after 3 attempts

## Key Principles

### First Principles Problem Analysis

Before any solution, validate the problem itself:

- What is the core problem separate from solutions?
- Could we solve this without building anything?
- What would success look like with unlimited resources?

### YAGNI (You Aren't Gonna Need It)

Aggressively cut unnecessary complexity:

- Unsure if needed? **Cut it**
- For "future flexibility"? **Cut it**
- Only 20% of users need it? **Cut it**

### Content Preservation

When creating tasks from specs:

- Copy implementation details verbatim
- Include complete code examples
- Each task must be self-contained

## Task Management Integration

### STM (Session Task Manager)

If installed, provides persistent task tracking across sessions:

```bash
stm list --pretty           # View all tasks
stm show <id>               # View task details
stm update <id> --status done  # Complete task
```

### TodoWrite (Fallback)

Built-in session task tracking when STM is unavailable.

## Requirements

- Claude Code CLI
- Optional: STM (Session Task Manager) for persistent task tracking

## License

MIT
