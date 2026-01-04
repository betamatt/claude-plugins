---
name: spec:execute
description: Implement a validated specification with review-fix loops
allowed-tools: Task, Read, TodoWrite, Grep, Glob, Bash(stm:*), Bash(jq:*)
argument-hint: "<path-to-spec-file>"
---

# Implement Specification

Implement the specification at: $ARGUMENTS

Check if STM is available by running `stm list`. If the command fails, STM is not installed.

## Pre-Execution Checks

1. **Check Task Management**:
   - If STM shows "Available but not initialized" -> Run `stm init` first, then `/spec:decompose` to create tasks
   - If STM shows "Available and initialized" -> Use STM for tasks
   - If STM shows "Not installed" -> Use TodoWrite instead

2. **Verify Specification**:
   - Confirm spec file exists and is complete
   - Check that required tools are available
   - Stop if anything is missing or unclear

## Implementation Process

### 1. Analyze Specification

Read the specification to understand:

- What components need to be built
- Dependencies between components
- Testing requirements
- Success criteria

### 2. Load or Create Tasks

**Using STM** (if available):

```bash
stm list --status pending -f json
```

**Using TodoWrite** (fallback):

Create tasks for each component in the specification

### 3. Implementation Workflow

For each task, follow this cycle:

#### Step 1: Implement

Implement the component directly, applying domain-specific best practices:

1. Run `stm show [task-id]` to get full task details
2. Implement based on requirements, following project code style
3. Add appropriate error handling
4. Reference CLAUDE.md for project conventions

#### Step 2: Write Tests

Write comprehensive tests for the implemented component:

1. Cover edge cases and aim for >80% coverage
2. Follow project testing patterns
3. Run tests to verify they pass

#### Step 3: Code Review with Fix Loop (Max 3 Iterations)

**Important:** Always run code review to verify both quality AND completeness. Task cannot be marked done without passing both. The review-fix loop runs a maximum of 3 times before escalating to the user.

```
iteration = 0
review_passed = false

while iteration < 3 and not review_passed:

  # Run code review
  Review implementation for BOTH:
  1. COMPLETENESS - Are all requirements from the task fully implemented?
  2. QUALITY - Code quality, security, error handling, test coverage

  Categorize issues as: CRITICAL, IMPORTANT, or MINOR.

  # Parse review output
  Extract issues by severity:
  - CRITICAL: Security vulnerabilities, crashes, data loss
  - IMPORTANT: Performance issues, missing error handling
  - MINOR: Style, docs (log but don't block)

  if no CRITICAL and no IMPORTANT issues:
    review_passed = true
    break

  # Fix issues
  For each CRITICAL issue:
    Fix immediately - these block completion

  For each IMPORTANT issue:
    Fix before marking task done

  # Re-run tests after fixes
  Run test suite to verify fixes don't break anything

  iteration++

# Handle max iterations reached
if iteration >= 3 and not review_passed:
  ESCALATE - Do NOT mark task done
  Report to user:
  - Which issues remain unresolved
  - What was attempted
  - Request manual intervention
```

#### Step 4: Update STM Status

**Auto-update protocol** - Always update STM status after review loop:

On success (review passed):

```bash
stm update [task-id] --status done --notes "Implemented, tested, reviewed - passed"
```

On escalation (max iterations reached):

```bash
stm update [task-id] --status blocked --notes "Review loop failed after 3 iterations - [remaining issues]"
```

Then notify the user of the escalation with details about remaining issues.

#### Step 5: Commit Changes

Create atomic commit following project conventions:

```bash
git add [files]
git commit -m "[follow project's commit convention]"
```

### 4. Track Progress

Monitor implementation progress:

**Using STM:**

```bash
stm list --pretty              # View all tasks
stm list --status pending      # Pending tasks
stm list --status in-progress  # Active tasks
stm list --status done         # Completed tasks
```

**Using TodoWrite:**

Track tasks in the session with status indicators.

### 5. Complete Implementation

Implementation is complete when:

- All tasks are COMPLETE (all requirements implemented)
- All tasks pass quality review (no critical issues)
- All tests passing
- Documentation updated

## If Issues Arise

If problems are encountered:

1. Identify the specific issue
2. Apply relevant domain knowledge to resolve
3. Or request user assistance if blocked
