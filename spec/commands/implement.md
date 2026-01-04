---
name: implement
description: End-to-end spec implementation with review loops - validates, decomposes, and executes sequentially
allowed-tools: Task, Read, Grep, Glob, Bash(stm:*), Bash(claudekit:*), Bash(git:*), Bash(jq:*), Bash(gh:*)
argument-hint: "<path-to-spec-file> [--pr]"
---

# End-to-End Spec Implementation

Implement the specification at: $ARGUMENTS

This command orchestrates the complete spec-to-code workflow:

1. Validate the specification
2. Decompose into tasks
3. Execute each task with review-fix loops
4. Optionally create a PR

## Parse Arguments

```
spec_path = first argument (required)
create_pr = true if "--pr" flag present
```

## Phase 1: Validate Specification

First, ensure the spec is ready for implementation.

Run validation by reading and analyzing the spec file:

1. Read the spec file at `spec_path`
2. Check for required sections:
   - **WHY**: Background, goals, success criteria
   - **WHAT**: Features, requirements, constraints
   - **HOW**: Implementation approach, architecture decisions
3. Identify any critical gaps

**If validation fails:**

```
## Specification Not Ready

Missing sections: [list]
Critical gaps: [list]

Would you like me to help refine the spec? I can:
1. Add missing sections with suggested content
2. Clarify ambiguous requirements
3. Fill in technical details

Or run /spec:validate for detailed feedback.
```

Ask the user if they want help refining the spec. If yes, work with them to address gaps, then re-validate.

**If validation passes:** Continue to Phase 2.

## Phase 2: Decompose into Tasks (Idempotent)

!claudekit status stm

Check STM status and initialize if needed:

- If "Available but not initialized" -> Run `stm init`
- If "Available and initialized" -> Ready to use
- If "Not installed" -> Will use TodoWrite fallback

**Check for existing tasks first** (enables resume after session termination):

```bash
# Check if tasks already exist for this spec
stm list --pretty
```

**If tasks already exist:**
- Skip decomposition
- Report: "Found existing tasks from previous run. Resuming execution."
- Continue to Phase 3

**If no tasks exist:**
Create task breakdown:

1. Read the spec to identify components
2. Create tasks for each component with:
   - Clear description
   - Full implementation details (copied from spec, not summarized)
   - Validation criteria
3. Add tasks to STM or TodoWrite

```bash
# List created tasks
stm list --pretty
```

## Phase 3: Execute Tasks Sequentially

For each pending task, use the task-executor agent:

```
# Get pending tasks
stm list --status pending -f json

For each task in order:

  # Mark as in-progress
  stm update [task-id] --status in-progress

  # Execute using task-executor agent
  Task tool:
  - description: "Execute [task-id]: [task-title]"
  - subagent_type: task-executor
  - prompt: |
      Execute this task from the spec implementation.

      Task ID: [task-id]

      Run `stm show [task-id]` to get full details.

      Follow the complete cycle:
      1. Implement based on task details
      2. Write tests
      3. Run review-fix loop (max 3 iterations)
      4. Update STM status when done
      5. Create atomic commit

      Report back with:
      - What was implemented
      - Test results
      - Review outcome
      - Any issues encountered

  # Check result
  If task-executor reports success:
    Continue to next task

  If task-executor reports escalation:
    STOP and report to user:
    - Which task is blocked
    - What issues remain
    - Request manual intervention
```

## Phase 4: Completion

When all tasks are done:

```bash
# Verify all tasks complete
stm list --status done
stm list --status pending  # Should be empty
stm list --status blocked  # Should be empty
```

### If `--pr` Flag Present

Create a pull request with the implementation:

```bash
# Get current branch
current_branch=$(git branch --show-current)

# Check if we need to push
git status

# Push if needed
git push -u origin $current_branch

# Create PR
gh pr create \
  --title "[Spec Implementation] [spec-name]" \
  --body "## Summary

Implements specification: $spec_path

## Tasks Completed

$(stm list --status done --format markdown)

## Testing

All tasks include tests that pass.

## Review

All tasks passed code review with no CRITICAL or IMPORTANT issues.

---
Generated with /spec:implement"
```

### Final Report

```
## Implementation Complete

Specification: [spec_path]
Tasks completed: [count]
Commits created: [count]
PR created: [url if --pr flag]

All requirements implemented and reviewed.
```

## Escalation Protocol

If any task cannot be completed after 3 review-fix iterations:

```
## Implementation Blocked

Task: [task-id] - [task-title]
Status: Blocked after 3 review iterations

Remaining Issues:
- [CRITICAL/IMPORTANT issue 1]
- [CRITICAL/IMPORTANT issue 2]

Attempts Made:
- Iteration 1: [what was tried]
- Iteration 2: [what was tried]
- Iteration 3: [what was tried]

Suggested Resolution:
[Recommendation for manual intervention]

To resume after fixing:
  stm update [task-id] --status pending
  /spec:implement [spec-path]
```

## Usage Examples

```bash
# Implement a feature spec
/spec:implement specs/feat-user-auth.md

# Implement and create PR
/spec:implement specs/feat-api-caching.md --pr
```
