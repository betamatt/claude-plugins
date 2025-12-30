---
name: set
description: Set debug verbosity level (off/minimal/normal/verbose)
argument-hint: <level>
allowed-tools: ["Read", "Write", "Bash"]
---

# Set Debug Verbosity Level

Set the verbosity level for claude-debugger logging.

## Usage

```
/debugger:set <level>
```

## Levels

- **off** - Disable all logging
- **minimal** - Log only skills and subagents
- **normal** - Log skills, subagents, commands, hooks
- **verbose** - Log everything including all tool calls and MCP

## Process

1. Validate the provided level is one of: off, minimal, normal, verbose
2. Read the current settings file at `.claude/debugger.yaml` (create if doesn't exist)
3. Update or set the `verbosity` field
4. Confirm the change to the user

## Settings File Format

```yaml
verbosity: normal
```

## Example

User runs: `/debugger:set verbose`

Response: "Debug verbosity set to **verbose**. All events will be logged to `.claude/debug.log`."
