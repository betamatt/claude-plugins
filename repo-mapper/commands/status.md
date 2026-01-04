---
name: status
description: Show RepoMapper installation status, cache info, and current configuration
allowed-tools: ["Read", "Bash"]
---

# RepoMapper Status

Display comprehensive status information about the RepoMapper installation.

## Process

### 1. Check Installation

```bash
# Check if RepoMapper is installed
if [ -d ".repo-mapper/RepoMapper" ]; then
    echo "Installed: Yes"
    echo "Location: .repo-mapper/RepoMapper/"
else
    echo "Installed: No"
    echo "Run /repo-mapper:setup to install"
fi
```

### 2. Check Python Environment

```bash
# Check for virtual environment
if [ -d ".repo-mapper/venv" ]; then
    echo "Python: .repo-mapper/venv/bin/python"
    .repo-mapper/venv/bin/python --version
else
    echo "Python: system (python3)"
    python3 --version
fi
```

### 3. Cache Information

```bash
# Check cache status
if [ -d ".repomap.tags.cache.v1" ]; then
    echo "Cache location: .repomap.tags.cache.v1/"
    echo "Cache size: $(du -sh .repomap.tags.cache.v1/ | cut -f1)"
    echo "Cache entries: $(find .repomap.tags.cache.v1 -type f | wc -l | tr -d ' ')"
else
    echo "Cache: Not created yet"
fi
```

### 4. Configuration

Read `.claude/repo-mapper.local.md` and display:
- token_limit
- auto_map
- exclude_unranked
- exclude_patterns

If config doesn't exist, show defaults.

### 5. Display Format

Present information in a clean, readable format:

```
RepoMapper Status
=================

Installation
------------
Status:    Installed
Location:  .repo-mapper/RepoMapper/
Python:    .repo-mapper/venv/bin/python (3.11.4)

Cache
-----
Location:  .repomap.tags.cache.v1/
Size:      2.4 MB
Entries:   156 files

Configuration (.claude/repo-mapper.local.md)
---------------------------------------------
Token limit:      8192
Auto-map:         enabled
Exclude unranked: no
Exclude patterns:
  - node_modules/**
  - vendor/**
  - .git/**
```

## Quick Checks

If not installed, suggest: `/repo-mapper:setup`
If cache is large (>50MB), suggest: `/repo-mapper:cache-clear`
