---
name: status
description: Show current debug configuration and log stats
allowed-tools: ["Read", "Bash"]
---

# Debug Status

Display current claude-debugger configuration and log file statistics.

## Usage

```
/debugger:status
```

## Process

1. Read settings from `.claude/claude-debugger.local.md` if it exists
2. Check if `.claude/debug.log` exists and get its stats
3. Display current configuration

## Output Format

```
Claude Debugger Status
─────────────────────
Verbosity: normal
Log file:  .claude/debug.log
Log size:  12.5 KB
Entries:   234

Recent activity:
  TOOL: 156 events
  AGENT: 12 events
  SKILL: 8 events
  CMD: 15 events
  HOOK: 43 events
```

## Implementation

1. Read verbosity from settings file (default: normal if not set)
2. Use `wc -l` to count log entries
3. Use `du -h` or `ls -lh` for file size
4. Use `jq` or `grep` to count events by type
5. Format and display the summary
