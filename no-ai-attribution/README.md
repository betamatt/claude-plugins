# no-ai-attribution

Prevents Claude from adding self-attribution to git commits.

## What it blocks

- `Co-Authored-By: Claude ...` trailer lines
- `Generated with Claude Code` footer messages

## How it works

A `PreToolUse` hook intercepts Bash tool calls. When a `git commit` command contains `Co-Authored-By` or `Generated with`, the hook blocks the command and asks Claude to retry without the attribution.

Normal commits are unaffected.
