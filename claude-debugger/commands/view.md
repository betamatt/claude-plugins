---
name: view
description: View recent debug log entries
argument-hint: [lines] [--type=TYPE]
allowed-tools: ["Read", "Bash"]
---

# View Debug Log

Display recent entries from the debug log file.

## Usage

```
/debugger:view [lines] [--type=TYPE]
```

## Arguments

- **lines** (optional) - Number of recent entries to show (default: 20)
- **--type=TYPE** (optional) - Filter by event type (TOOL, AGENT, SKILL, CMD, HOOK, MCP)

## Examples

```
/debugger:view              # Show last 20 entries
/debugger:view 50           # Show last 50 entries
/debugger:view --type=AGENT # Show last 20 agent events
/debugger:view 10 --type=TOOL # Show last 10 tool events
```

## Process

1. Check if `.claude/debug.log` exists
2. If type filter specified, use `grep` to filter by type
3. Use `tail` to get the requested number of lines
4. Parse JSON and display in readable format

## Output Format

Display each log entry in a readable format:

```
2024-01-15T14:32:05Z [TOOL] Read → /src/app.ts
2024-01-15T14:32:06Z [TOOL] Edit → /src/app.ts
2024-01-15T14:32:07Z [AGENT] code-search → completed
2024-01-15T14:32:10Z [SKILL] rails-conventions → loaded
```

## Implementation

1. Read log file: `.claude/debug.log`
2. Apply type filter if specified: `grep '"type":"AGENT"'`
3. Get last N lines: `tail -n $LINES`
4. Parse JSON entries and format for display
5. If log doesn't exist, inform user to enable debugging first
