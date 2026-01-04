---
name: focus
description: Generate a repository map with specific files prioritized for relevance
argument-hint: "<files...> [--tokens <limit>]"
allowed-tools: ["Bash", "Read", "Glob"]
---

# Generate Focused Repository Map

Generate a repository map with specific files prioritized using RepoMapper's `--chat-files` feature.

## Arguments

- `<files...>`: One or more file paths or glob patterns to prioritize (required)
- `--tokens <N>`: Override token limit (default: from config or 8192)

## Process

### 1. Verify Installation

```bash
ls .repo-mapper/RepoMapper/repomap.py
```

If not installed, tell the user to run `/repo-mapper:setup` first.

### 2. Parse and Expand File Arguments

Extract file paths from arguments. If glob patterns are provided, expand them:

Use the Glob tool to expand patterns like `src/**/*.ts` into actual file paths.

Validate that the specified files exist.

### 3. Load Configuration

Read `.claude/repo-mapper.local.md` if it exists to get token_limit and other settings.

### 4. Build Command

Construct the repomap command with `--chat-files` for prioritization:

```bash
.repo-mapper/venv/bin/python .repo-mapper/RepoMapper/repomap.py \
    --map-tokens <token_limit> \
    --chat-files <file1> <file2> ... \
    .
```

The `--chat-files` flag tells RepoMapper to give highest PageRank priority to these files.

### 5. Execute and Display

Run the command:
```bash
.repo-mapper/venv/bin/python .repo-mapper/RepoMapper/repomap.py \
    --map-tokens 8192 \
    --chat-files src/main.ts src/utils.ts \
    .
```

### 6. Present Results

Display the focused repository map, highlighting:
- Which files were prioritized
- Related files and dependencies
- Function/class definitions in the focus area

## Usage Examples

```
/repo-mapper:focus src/auth/           # Focus on auth directory
/repo-mapper:focus src/api/*.ts        # Focus on API TypeScript files
/repo-mapper:focus main.py utils.py    # Focus on specific files
/repo-mapper:focus src/core/** --tokens 4096  # Focus with smaller budget
```

## When to Use

- Starting work on a specific feature or module
- Debugging an issue in particular files
- Understanding dependencies of specific code
- Getting context for a code review
