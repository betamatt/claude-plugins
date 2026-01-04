---
name: map
description: Generate an AI-optimized repository map showing important files and code structure
argument-hint: "[--tokens <limit>] [--verbose]"
allowed-tools: ["Bash", "Read"]
---

# Generate Repository Map

Generate a prioritized repository map using Tree-sitter parsing and PageRank algorithm.

## Arguments

- `--tokens <N>`: Override token limit (default: from config or 8192)
- `--verbose`: Show detailed processing information

## Process

### 1. Verify Installation

```bash
ls .repo-mapper/RepoMapper/repomap.py
```

If not installed, tell the user to run `/repo-mapper:setup` first.

### 2. Load Configuration

Read `.claude/repo-mapper.local.md` if it exists to get:
- `token_limit`: Token budget for the map
- `exclude_unranked`: Whether to skip zero-ranked files
- `exclude_patterns`: Patterns to exclude

Parse any command-line arguments to override config values.

### 3. Build Command

Determine Python executable:
```bash
PYTHON=".repo-mapper/venv/bin/python"
if [ ! -f "$PYTHON" ]; then
    PYTHON="python3"
fi
```

Build the repomap command:
```bash
$PYTHON .repo-mapper/RepoMapper/repomap.py \
    --map-tokens <token_limit> \
    [--exclude-unranked] \
    [--verbose] \
    .
```

### 4. Execute and Display

Run the command and capture output:
```bash
cd "$(pwd)" && .repo-mapper/venv/bin/python .repo-mapper/RepoMapper/repomap.py --map-tokens 8192 .
```

### 5. Present Results

Display the repository map output, which shows:
- Prioritized list of important files
- Function and class definitions
- Symbol relationships

If the map is useful context, note that it's now available for reference during the session.

## Usage Examples

```
/repo-mapper:map                    # Generate with default settings
/repo-mapper:map --tokens 4096      # Smaller context window
/repo-mapper:map --verbose          # Show processing details
```
