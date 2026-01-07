---
name: spec:implement
description: End-to-end spec implementation with review loops - validates, decomposes, and executes sequentially
allowed-tools: Task, Read, Grep, Glob, Bash(stm:*), Bash(git:*), Bash(jq:*), Bash(gh:*)
argument-hint: "<path-to-spec-file> [--pr]"
---

# End-to-End Spec Implementation

Implement the specification at: $ARGUMENTS

This command orchestrates the complete spec-to-code workflow:

1. Validate the specification
2. Readiness check - clarify ambiguities, confirm understanding
3. Decompose into tasks
4. Execute each task with review-fix loops
5. Optionally create a PR

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

## Phase 2: Readiness Check

Before decomposing, ensure the spec is clear enough for autonomous implementation.

### Analyze for Ambiguities

Review the spec and identify:

1. **Ambiguous requirements** - vague language, multiple interpretations
2. **Missing details** - error handling, edge cases, defaults not specified
3. **Technical decisions needed** - library choices, patterns, approaches
4. **Dependencies on user context** - existing code patterns, preferences, constraints

### Ask Clarifying Questions

If any ambiguities or gaps are found:

```
## Before I Begin Implementation

I've reviewed the spec and have some questions to ensure I implement this correctly:

### Questions
1. [Question about ambiguous requirement]
2. [Question about missing detail]
3. [Question about technical choice]

### Assumptions I'll Make (unless you correct me)
- [Assumption 1]
- [Assumption 2]

### Additional Context Needed
- [Any files, examples, or information that would help]

Please answer these questions, or let me know if you'd like to proceed with my assumptions.
```

**Wait for user response before continuing.**

### Confirm Readiness

Once questions are answered:

```
## Ready to Implement

I have enough context to proceed. Here's my understanding:

- [Summary of key requirements]
- [Technical approach]
- [Any constraints or preferences noted]

Shall I proceed with decomposition and implementation?
```

**Wait for explicit user confirmation before continuing to Phase 3.**

## Phase 3: Decompose into Tasks (Idempotent)

Check if STM is available by running `stm list`. If the command fails, STM is not installed.

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
- Continue to Phase 4

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

## Phase 4: Execute Tasks Sequentially

For each pending task, select the most appropriate expert agent and execute:

```
# Get pending tasks
stm list --status pending -f json

For each task in order:

  # Mark as in-progress
  stm update [task-id] --status in-progress

  # Analyze task to select best agent type
  # Read task details: stm show [task-id]
  # Based on technologies, file types, and domain:
  #   - TypeScript/JavaScript → typescript-expert or nodejs-expert
  #   - React/Next.js → react-expert
  #   - PostgreSQL/database → postgres-expert or database-expert
  #   - Docker/infrastructure → docker-expert or devops-expert
  #   - GitHub Actions/CI → github-actions-expert
  #   - Generic/mixed → task-executor

  # Execute using selected agent
  Task tool:
  - description: "Execute [task-id]: [task-title]"
  - subagent_type: [selected-expert-agent]
  - prompt: |
      Execute this task from a spec implementation.

      Task ID: [task-id]

      Run `stm show [task-id]` to get full task details including requirements
      and acceptance criteria.

      Follow TDD red/green cycles:

      1. **RED**: Write failing test(s) for the first requirement
         - Test should fail with clear error showing missing functionality
         - Run tests to confirm they fail

      2. **GREEN**: Write minimal code to make test(s) pass
         - Only implement what's needed to pass the current test
         - Run tests to confirm they pass

      3. **REFACTOR**: Clean up if needed while keeping tests green

      4. Repeat steps 1-3 for each requirement in the task

      5. Run code review (use code-review-expert agent), fix CRITICAL/IMPORTANT issues (max 3 iterations)

      6. Update STM when done: `stm update [task-id] --status done`

      7. Create atomic commit: `git commit -m "[task-id]: [description]"`

      If blocked after 3 review iterations, update STM to blocked and escalate.

      Report back with:
      - TDD cycles completed (which tests drove which implementation)
      - Final test results
      - Review outcome
      - Any issues encountered

  # Check result
  If agent reports success:
    Continue to next task

  If agent reports escalation:
    STOP and report to user:
    - Which task is blocked
    - What issues remain
    - Request manual intervention
```

## Phase 5: Completion

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
