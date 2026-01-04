# RepoMapper Plugin

AI-optimized repository mapping for Claude Code using [RepoMapper](https://github.com/pdavis68/RepoMapper) - a Tree-sitter-powered code analyzer with PageRank prioritization.

## Features

- **Smart Code Analysis**: Tree-sitter parses 30+ programming languages
- **PageRank Prioritization**: Important files surface automatically based on reference patterns
- **Token-Aware Output**: Maps fit within LLM context windows with binary search optimization
- **Focused Mapping**: Prioritize specific files for targeted context
- **Auto-Generation**: Optionally generate maps on session start
- **Per-Project Installation**: Each project gets its own isolated RepoMapper instance

## Requirements

- Python 3.8+
- Git (for initial installation)
- ~100MB disk space for dependencies

## Quick Start

1. **Install RepoMapper to your project:**
   ```
   /repo-mapper:setup
   ```

2. **Generate a repository map:**
   ```
   /repo-mapper:map
   ```

3. **Focus on specific files:**
   ```
   /repo-mapper:focus src/auth/**
   ```

## Commands

| Command | Description |
|---------|-------------|
| `/repo-mapper:setup` | Install RepoMapper to `.repo-mapper/` |
| `/repo-mapper:map` | Generate full repository map |
| `/repo-mapper:focus <files>` | Generate map with specific files prioritized |
| `/repo-mapper:cache-clear` | Clear the Tree-sitter analysis cache |
| `/repo-mapper:config` | View or modify settings |
| `/repo-mapper:status` | Show installation and cache status |

## Configuration

Settings are stored in `.claude/repo-mapper.local.md` and can be modified with `/repo-mapper:config`:

| Setting | Default | Description |
|---------|---------|-------------|
| `token_limit` | 8192 | Maximum tokens for generated maps |
| `auto_map` | true | Generate map automatically on session start |
| `exclude_unranked` | false | Skip files with zero PageRank score |
| `exclude_patterns` | (see below) | Glob patterns to exclude from analysis |

Default exclude patterns:
- `node_modules/**`
- `vendor/**`
- `.git/**`
- `*.min.js`
- `dist/**`
- `build/**`

## How It Works

RepoMapper uses a multi-stage pipeline:

1. **Discovery**: Finds all source files in the project
2. **Parsing**: Tree-sitter extracts function/class definitions and references
3. **Graph Building**: Creates a reference graph of files and symbols
4. **PageRank**: Calculates importance scores based on reference patterns
5. **Optimization**: Binary search to fit maximum content in token budget
6. **Output**: Formatted map with prioritized files and definitions

## Project Structure

After setup, your project will have:

```
your-project/
├── .repo-mapper/           # RepoMapper installation (git-ignored)
│   ├── RepoMapper/         # Cloned repository
│   └── venv/               # Python virtual environment
├── .claude/
│   └── repo-mapper.local.md  # Configuration file
└── .repomap.tags.cache.v1/ # Analysis cache (auto-generated)
```

## Tips

### For Large Codebases
Increase exclusions to focus on important code:
```
/repo-mapper:config exclude_patterns "**/*.test.ts,**/__mocks__/**,docs/**"
```

### For Smaller Context Windows
Reduce token limit:
```
/repo-mapper:config token_limit 4096
```

### For Fresh Analysis
Clear cache when needed:
```
/repo-mapper:cache-clear
```

## Troubleshooting

**Setup fails with "Python not found"**
- Ensure Python 3.8+ is installed and in PATH
- Try `python3 --version` to verify

**Map generation is slow**
- First run builds the cache; subsequent runs are faster
- Large repos (>10k files) take longer initially

**"No parseable files found"**
- Check that your source files use supported extensions
- Verify exclude patterns aren't too aggressive

## Credits

This plugin integrates [RepoMapper](https://github.com/pdavis68/RepoMapper) by pdavis68, which uses:
- [Tree-sitter](https://tree-sitter.github.io/) for code parsing
- [NetworkX](https://networkx.org/) for graph analysis
- [tiktoken](https://github.com/openai/tiktoken) for token counting
