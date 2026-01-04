---
name: Repository Mapping
description: |
  This skill should be used when the user asks about "repo map", "repository structure",
  "codebase overview", "important files", "code navigation", "project structure",
  "understanding the codebase", "code context", "file dependencies", or needs guidance
  on using RepoMapper for AI-optimized context generation.
version: 1.0.0
---

# Repository Mapping with RepoMapper

RepoMapper generates AI-optimized repository maps using Tree-sitter parsing and PageRank algorithms to prioritize the most relevant code for LLM context windows.

## When to Use Repository Maps

- **Starting on unfamiliar code**: Get an overview of project structure and important files
- **Understanding dependencies**: See how files and modules relate to each other
- **Focused development**: Prioritize specific files when working on a feature
- **Code review context**: Understand surrounding code for better reviews
- **Large codebase navigation**: Find entry points and key files quickly

## Core Concepts

### PageRank Prioritization

RepoMapper analyzes code references to determine file importance:
- Files referenced by many others rank higher
- Entry points and utilities naturally surface to the top
- Test files and generated code rank lower
- The algorithm mirrors how developers naturally think about code importance

### Token-Aware Output

Maps are generated within configurable token budgets:
- Default: 8192 tokens (fits most LLM context windows)
- Configurable per-project via `/repo-mapper:config`
- Binary search optimization ensures optimal content for the budget
- Important content is never truncated mid-definition

### Tree-sitter Multi-Language Parsing

RepoMapper uses Tree-sitter for accurate code analysis:
- Extracts function and class definitions
- Identifies symbol references across files
- Supports 30+ programming languages including:
  - Python, JavaScript, TypeScript
  - Go, Rust, Java, C/C++
  - Ruby, PHP, Swift, Kotlin
  - And many more

## Commands Reference

| Command | Description |
|---------|-------------|
| `/repo-mapper:setup` | Install RepoMapper to project |
| `/repo-mapper:map` | Generate full repository map |
| `/repo-mapper:focus <files>` | Prioritize specific files |
| `/repo-mapper:cache-clear` | Clear parsing cache |
| `/repo-mapper:config` | Configure settings |
| `/repo-mapper:status` | Show installation status |

## Configuration Options

Settings are stored in `.claude/repo-mapper.local.md`:

- **token_limit** (default: 8192): Maximum tokens for maps
- **auto_map** (default: true): Generate map on session start
- **exclude_unranked** (default: false): Skip zero-ranked files
- **exclude_patterns**: Glob patterns to exclude (node_modules, dist, etc.)

## Best Practices

### For Focused Development

When working on a specific feature:
```
/repo-mapper:focus src/auth/** src/middleware/auth.ts
```

This prioritizes auth-related files and their dependencies.

### For Large Codebases

Increase exclusions to reduce noise:
```
/repo-mapper:config exclude_patterns "**/*.test.ts,**/__tests__/**,docs/**"
```

### For Context Window Optimization

Adjust token limit based on your needs:
- Small context (Claude Haiku): `--tokens 4096`
- Standard context: `--tokens 8192`
- Large context: `--tokens 16384`

## Additional Resources

For detailed MCP tool documentation, see:
- [references/mcp-tools.md](references/mcp-tools.md) - MCP server tool parameters
