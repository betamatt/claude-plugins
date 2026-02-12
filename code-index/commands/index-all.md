---
name: code-index:index-all
description: Index all active Conductor workspace directories
allowed-tools: ["Bash", "Glob"]
---

Index all active Conductor workspace directories for code search.

## Process

1. Find all workspace directories by listing subdirectories under each project in `/Users/matt/conductor/workspaces/`:
   - Each project (e.g., seraph-agent) contains workspace directories (e.g., prague, krakow-v1)
   - Only include directories that contain a `.git` file or directory (valid worktrees)

2. For each workspace directory found, call the `index_directory` MCP tool.

3. Report a summary: how many directories were indexed, any failures.
