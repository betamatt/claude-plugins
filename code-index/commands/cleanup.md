---
name: code-index:cleanup
description: Remove indexes for directories that no longer exist on disk
allowed-tools: ["Bash"]
---

Clean up stale code search indexes.

## Process

1. Call `list_indexes` MCP tool to get all currently indexed directories.
2. For each indexed directory, check if it still exists on disk.
3. For directories that no longer exist, call `delete_index` MCP tool to remove the stale index.
4. Report what was removed and what remains.
