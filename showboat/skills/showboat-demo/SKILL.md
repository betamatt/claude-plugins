---
name: showboat-demo
description: "Create executable Markdown demos using showboat to prove features work. Use after implementing features or fixing bugs to produce reproducible proof-of-work documents."
version: 1.0.0
---

# Showboat Demos

## Overview

Showboat is a CLI tool that constructs Markdown documents by capturing real command output. Each `exec` block runs a command, records the output, and appends both to the document. The result is a reproducible demo that proves code works — not just that tests pass.

Install: `go install github.com/simonw/showboat@latest`

## When to Use

- After implementing a new feature or API endpoint
- After fixing a bug that affected observable behavior
- When onboarding documentation needs live examples
- When a PR would benefit from proof-of-work beyond test results

Do NOT use for:
- Internal implementation details (test those with unit tests)
- Workflows requiring complex auth flows that can't be reproduced locally

## Core Workflow

```
init → note → exec → exec → ... → verify
```

1. **init**: Create the document with a title
2. **note**: Add descriptive text explaining what follows
3. **exec**: Run a command and capture its output
4. **verify**: Re-run all commands and confirm outputs match

## Example: API Demo

```bash
# Create the demo document
showboat init demos/users-api.md 'Users API'

# Describe what we're demonstrating
showboat note demos/users-api.md 'Create a user and verify the response'

# Execute and capture API calls
showboat exec demos/users-api.md bash \
  'curl -s -X POST http://localhost:3000/users \
   -H "Content-Type: application/json" \
   -d "{\"name\":\"test\"}" | jq .'

showboat exec demos/users-api.md bash \
  'curl -s http://localhost:3000/users | jq .'

# Verify the demo is reproducible
showboat verify demos/users-api.md
```

## Example: CLI Tool Demo

```bash
showboat init demos/my-cli.md 'My CLI Tool'

showboat note demos/my-cli.md 'Show help output'
showboat exec demos/my-cli.md bash 'my-cli --help'

showboat note demos/my-cli.md 'Run a basic command'
showboat exec demos/my-cli.md bash 'my-cli process input.txt'

showboat verify demos/my-cli.md
```

### Naming Convention

Name demo files after the feature: `demos/<feature>.md`

Examples: `demos/users-api.md`, `demos/email-sync.md`, `demos/search.md`

## Error Recovery

If an `exec` captures bad output (wrong response, error, etc.):

```bash
# Remove the last section
showboat pop demos/feature.md

# Fix the issue, then retry
showboat exec demos/feature.md bash 'fixed-command'
```

`pop` removes the most recent entry (note, exec, or image). Call it multiple times to remove multiple entries.

## Verification

`verify` re-runs every `exec` block and compares output to what was recorded:

```bash
showboat verify demos/feature.md
```

- Exit code 0: all outputs match
- Exit code 1: outputs differ (demo is stale or non-reproducible)

Use `--output` to write an updated version without modifying the original:

```bash
showboat verify demos/feature.md --output demos/feature-updated.md
```

## Best Practices

1. **One concept per demo** — a single feature or short workflow, not an entire surface area
2. **Progressive complexity** — start with the simplest call, then show variations
3. **Use jq for formatting** — pipe JSON output through `jq .` for readability
4. **Add -s to curl** — suppress progress bars (`curl -s`)
5. **Narrate with notes** — explain what each exec block demonstrates
6. **Verify before committing** — always run `showboat verify` to confirm reproducibility
7. **Idempotent demos** — prefer read operations or use unique test data so demos can re-run cleanly
