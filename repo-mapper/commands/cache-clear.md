---
name: cache-clear
description: Clear RepoMapper's analysis cache for fresh code parsing
allowed-tools: ["Bash"]
---

# Clear RepoMapper Cache

Remove the RepoMapper disk cache to force fresh analysis on next map generation.

## Process

### 1. Locate Cache Directory

RepoMapper stores its cache in `.repomap.tags.cache.v1/` in the project root.

### 2. Check Cache Status

```bash
# Check if cache exists and get size
if [ -d ".repomap.tags.cache.v1" ]; then
    du -sh .repomap.tags.cache.v1/
    find .repomap.tags.cache.v1 -type f | wc -l
fi
```

### 3. Clear Cache

```bash
rm -rf .repomap.tags.cache.v1/
```

### 4. Report Results

Display:
- How much disk space was freed
- Note that next map generation will be slower (rebuilding cache)

## When to Use

- After significant code changes that might not be reflected
- If you suspect stale or corrupted cache data
- To troubleshoot unexpected map results
- After updating RepoMapper itself

## Note

The cache is automatically invalidated when individual files change, so manual clearing is rarely needed. Use this when you want to ensure a completely fresh analysis.
