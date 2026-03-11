---
name: demo
description: Create an executable showboat demo for a feature
argument-hint: "<feature-name>"
allowed-tools: ["Bash", "Read", "Write", "Edit", "Grep", "Glob"]
---

# Create a Showboat Demo

Build an executable Markdown demo for the feature: **$ARGUMENTS**

## Prerequisites

First, check that showboat is installed:

```bash
which showboat || echo "NOT INSTALLED"
```

If not installed, install it with `go install github.com/simonw/showboat@latest`.

## Process

1. **Understand the feature** — Read the relevant source code to understand what the feature does and how to exercise it. Look for API endpoints, CLI commands, or functions that produce observable output.

2. **Create the demo directory** if it doesn't exist:
   ```bash
   mkdir -p demos
   ```

3. **Initialize the demo document**:
   ```bash
   showboat init demos/<feature-name>.md '<Feature Title>'
   ```

4. **Build the demo** by alternating `note` and `exec` blocks:
   - Add a `note` explaining what you're about to demonstrate
   - Add an `exec` that runs a real command and captures its output
   - Repeat for each aspect of the feature
   - Start simple, then show more complex usage

5. **Verify** the demo is reproducible:
   ```bash
   showboat verify demos/<feature-name>.md
   ```

6. If verification fails, use `showboat pop` to remove bad entries and re-record.

## Guidelines

- Use the feature name from $ARGUMENTS to name the demo file
- One concept per demo — keep it focused
- Use `jq .` for JSON output formatting
- Use `curl -s` to suppress progress bars
- Add descriptive notes before each exec block
- Ensure commands are idempotent so the demo can be re-verified
- If the feature requires a running server, note that in the first `showboat note`

## Output

When complete, show the user:
1. The path to the demo file
2. The verification result
3. A brief summary of what the demo covers
