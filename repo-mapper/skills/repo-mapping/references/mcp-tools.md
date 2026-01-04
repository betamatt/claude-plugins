# RepoMapper MCP Tools Reference

Detailed documentation for the MCP tools provided by the RepoMapper server.

## repo_map Tool

The primary tool for generating repository maps with prioritized files and symbols.

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `project_root` | string | Yes | - | Absolute path to the project directory |
| `chat_files` | list | No | [] | Files in current context (highest PageRank boost) |
| `mentioned_files` | list | No | [] | Explicitly mentioned files (medium boost) |
| `other_files` | list | No | [] | Additional relevant files (lower boost) |
| `token_limit` | int | No | 8192 | Maximum tokens for output |
| `exclude_unranked` | bool | No | false | Exclude files with zero PageRank |
| `force_refresh` | bool | No | false | Bypass cache, force fresh analysis |
| `mentioned_idents` | list | No | [] | Mentioned identifiers to boost |
| `verbose` | bool | No | false | Enable detailed logging |
| `max_context_window` | int | No | null | Override context window size |

### File Priority Levels

RepoMapper uses three priority tiers:

1. **chat_files** (Highest): Files you're actively working on
   - Get maximum PageRank boost
   - Always included if they exist
   - Use for current focus area

2. **mentioned_files** (Medium): Files referenced in conversation
   - Get moderate PageRank boost
   - Included when space permits
   - Use for related context

3. **other_files** (Lower): Supplementary context
   - Get minimal PageRank boost
   - Included if space remains
   - Use for background context

### Return Value

```json
{
  "map": "Repository map as formatted string with file paths and definitions...",
  "report": {
    "included_files": ["src/main.py", "src/utils.py"],
    "excluded_files": ["tests/test_main.py"],
    "match_counts": {
      "definitions": 45,
      "references": 128
    }
  },
  "error": null
}
```

### Example Usage

Basic map generation:
```python
repo_map(
    project_root="/path/to/project"
)
```

Focused map with priority files:
```python
repo_map(
    project_root="/path/to/project",
    chat_files=["src/auth/login.ts", "src/auth/session.ts"],
    token_limit=4096
)
```

Force fresh analysis:
```python
repo_map(
    project_root="/path/to/project",
    force_refresh=True,
    verbose=True
)
```

## Output Format

The generated map includes:

```
src/auth/login.ts:
│   class LoginService
│       constructor(authProvider)
│       async login(credentials)
│       async validateToken(token)
│
│   function hashPassword(password)
│   function verifyPassword(password, hash)

src/auth/session.ts:
│   class SessionManager
│       createSession(user)
│       destroySession(sessionId)
│       refreshSession(sessionId)
```

Files are sorted by PageRank (most important first), and definitions are shown with their signatures.

## Caching Behavior

RepoMapper uses disk caching for performance:

- **Cache location**: `.repomap.tags.cache.v1/` in project root
- **Invalidation**: Automatic when file content changes (by hash)
- **Force refresh**: Use `force_refresh=True` to bypass cache
- **Manual clear**: Delete the cache directory

## Error Handling

Common errors and solutions:

| Error | Cause | Solution |
|-------|-------|----------|
| `project_root not found` | Invalid path | Verify path exists |
| `No parseable files` | No supported languages | Check file extensions |
| `Token limit too small` | Can't fit any content | Increase token_limit |
| `Cache corrupted` | Disk issues | Use force_refresh or clear cache |
