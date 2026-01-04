---
name: config
description: Configure RepoMapper settings (token limits, exclusions, auto-map)
argument-hint: "[setting] [value]"
allowed-tools: ["Read", "Write"]
---

# Configure RepoMapper

View or modify RepoMapper settings stored in `.claude/repo-mapper.local.md`.

## Arguments

- No arguments: Display current configuration
- `<setting>`: Show value of specific setting
- `<setting> <value>`: Update setting to new value

## Available Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `token_limit` | integer | 8192 | Maximum tokens for generated maps |
| `auto_map` | boolean | true | Generate map on session start |
| `exclude_unranked` | boolean | false | Skip files with zero PageRank |
| `exclude_patterns` | list | see below | Glob patterns to exclude |

Default exclude patterns:
- `node_modules/**`
- `vendor/**`
- `.git/**`
- `*.min.js`
- `dist/**`
- `build/**`

## Process

### No Arguments - Show All Settings

Read `.claude/repo-mapper.local.md` and display all current settings with their values. If the file doesn't exist, show defaults.

### Single Argument - Show Setting

Display the current value of the specified setting.

### Two Arguments - Update Setting

1. Read the current config file (or create if missing)
2. Parse the YAML frontmatter
3. Update the specified setting
4. Write back the updated file

For `exclude_patterns`, accept comma-separated values:
```
/repo-mapper:config exclude_patterns "*.test.ts,dist/**,coverage/**"
```

For boolean settings, accept: true/false, yes/no, on/off, 1/0

### Validation

- `token_limit`: Must be positive integer, typically 1024-32768
- `auto_map`: Must be boolean
- `exclude_unranked`: Must be boolean
- `exclude_patterns`: Must be valid glob patterns

## Usage Examples

```
/repo-mapper:config                              # Show all settings
/repo-mapper:config token_limit                  # Show token limit
/repo-mapper:config token_limit 4096             # Set token limit
/repo-mapper:config auto_map false               # Disable auto-mapping
/repo-mapper:config exclude_patterns "*.test.ts,__tests__/**"
```
