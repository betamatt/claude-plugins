# Claude Debugger

A flexible logging and debugging system for Claude Code plugins. Track skills, subagents, hooks, tools, commands, and MCP calls with configurable verbosity.

## Features

- **Event Logging**: Capture all Claude Code internal events to a JSON log file
- **Configurable Verbosity**: Control what gets logged with 4 verbosity levels
- **No Conversation Interruption**: All logging goes to a file, keeping your conversation clean
- **Project-Level Logs**: Each project has its own debug log in `.claude/debug.log`

## Installation

```bash
claude plugins install claude-debugger
```

Or for local development:

```bash
claude --plugin-dir /path/to/claude-debugger
```

## Commands

### `/debugger:set <level>`

Set the verbosity level for logging.

```bash
/debugger:set verbose    # Log everything
/debugger:set normal     # Log skills, agents, commands, hooks
/debugger:set minimal    # Log only skills and agents
/debugger:set off        # Disable logging
```

### `/debugger:status`

Show current configuration and log statistics.

```bash
/debugger:status
```

### `/debugger:view [lines] [--type=TYPE]`

View recent log entries.

```bash
/debugger:view              # Last 20 entries
/debugger:view 50           # Last 50 entries
/debugger:view --type=AGENT # Filter by type
```

## Verbosity Levels

| Level | Events Logged |
|-------|---------------|
| off | Nothing |
| minimal | Skills, Subagents |
| normal | Skills, Subagents, Commands, Hooks |
| verbose | Everything (including all tool calls, MCP) |

## Log Format

Logs are stored as JSON lines in `.claude/debug.log`:

```json
{"time":"2024-01-15T14:32:05Z","type":"TOOL","name":"Read","detail":"/src/app.ts"}
{"time":"2024-01-15T14:32:06Z","type":"AGENT","name":"code-search","detail":"completed"}
{"time":"2024-01-15T14:32:07Z","type":"SKILL","name":"rails-conventions"}
```

## Configuration

Settings are stored in `.claude/debugger.yaml`:

```yaml
verbosity: normal
```

## Event Types

- **SKILL** - Skill activation
- **AGENT** - Subagent invocation
- **HOOK** - Hook execution
- **TOOL** - Tool invocation (Read, Write, Bash, etc.)
- **CMD** - Command execution
- **MCP** - MCP server calls

## Use Cases

- **Plugin Development**: See which skills and agents trigger during development
- **Debugging**: Track tool usage to understand Claude's behavior
- **Performance**: Identify which operations are being called frequently
- **Learning**: Understand how Claude Code works internally

## License

MIT
