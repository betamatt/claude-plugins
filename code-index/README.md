# code-index

Fast code search across Conductor workspaces using [code-index-mcp](https://github.com/trondhindenes/code-index-mcp) (Zoekt trigram indexing exposed as an MCP server).

## Prerequisites

Install the code-index-mcp binary:

```bash
go install github.com/trondhindenes/code-index-mcp@latest
```

Ensure `$GOPATH/bin` (typically `~/go/bin`) is in your PATH.

## What It Does

- **MCP Server**: Registers `code-index-mcp` as an MCP server, giving Claude access to `index_directory`, `search_code`, `list_indexes`, `delete_index`, and `index_info` tools
- **Auto-indexing**: SessionStart hook silently indexes the current workspace on first use
- **Commands**: Slash commands for bulk indexing and cleanup

## Commands

| Command | Description |
|---------|-------------|
| `/code-index:index [dir]` | Index a directory (defaults to current) |
| `/code-index:index-all` | Index all active Conductor workspaces |
| `/code-index:list` | List all indexed directories |
| `/code-index:cleanup` | Remove indexes for deleted directories |

## Search

Once directories are indexed, Claude can use the `search_code` MCP tool directly. Zoekt query syntax supports:

- `func main` - text search
- `file:\.go$ func main` - filter by file extension
- `lang:python class.*Model` - filter by language
- `-test func main` - exclude files containing "test"
- `case:yes MyFunc` - case-sensitive search

## Getting Started

1. Install the binary (see Prerequisites)
2. Enable this plugin in Claude Code
3. Run `/code-index:index-all` to index all existing workspaces
4. New workspaces are auto-indexed on first session
