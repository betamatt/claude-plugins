---
name: code-index:index
description: Index a directory for code search
argument-hint: "[directory-path]"
allowed-tools: []
---

Index a directory for fast code search using the code-index MCP tools.

If an argument is provided, index that directory: $ARGUMENTS
If no argument is provided, index the current working directory.

Use the `index_directory` MCP tool with the resolved absolute path.
After indexing, confirm what was indexed.
