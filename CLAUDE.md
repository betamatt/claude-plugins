# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Claude Code plugins repository containing official plugins for specialized development workflows. Each plugin provides agents, commands, skills, and hooks that enhance Claude Code's capabilities for specific frameworks or technologies.

## Plugin Structure

Plugins follow this standard structure:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (name, version, description)
├── agents/                   # Specialized subagents (*.md with YAML frontmatter)
├── commands/                 # Slash commands (*.md with YAML frontmatter)
├── hooks/
│   └── hooks.json           # Event hooks (SessionStart, PreToolUse, etc.)
├── skills/
│   └── skill-name/
│       ├── SKILL.md         # Skill definition with YAML frontmatter
│       └── references/      # Supporting documentation
└── README.md
```

## Component Formats

### Agents (agents/*.md)
```yaml
---
name: agent-name
description: When to trigger this agent (with <example> blocks)
model: inherit|sonnet|opus|haiku
color: green|yellow|blue|red
tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash"]
---
System prompt content...
```

### Commands (commands/*.md)
```yaml
---
name: command-name
description: Short description
argument-hint: <required> [optional]
allowed-tools: ["Read", "Bash", ...]
---
Command instructions...
```

### Skills (skills/*/SKILL.md)
```yaml
---
name: Skill Name
description: Trigger keywords and when to activate
version: 1.0.0
---
Skill content with examples and patterns...
```

### Hooks (hooks/hooks.json)
```json
{
  "hooks": [
    {
      "event": "SessionStart|PreToolUse|PostToolUse|Stop",
      "type": "prompt",
      "prompt": "Instructions for the hook"
    }
  ]
}
```

## Current Plugins

### ruby-on-rails
Professional Rails 7+ development toolkit with:
- **Agents**: rails-expert, migration-expert, performance-expert, security-expert (proactive activation)
- **Commands**: /rails:generate, /rails:migrate, /rails:db
- **Skills**: rails-conventions, activerecord-patterns, rails-testing
- **Hooks**: SessionStart for automatic Rails project detection

## Marketplace Configuration

The root `.claude-plugin/marketplace.json` defines which plugins are published:

```json
{
  "name": "claude-plugins",
  "plugins": [
    { "name": "plugin-name", "source": "./plugin-name", ... }
  ]
}
```

## Key Conventions

- Agent descriptions must include `<example>` blocks showing trigger conditions
- Skills use `references/` subdirectories for detailed documentation that loads on demand
- Commands specify `allowed-tools` to restrict tool access during execution
- Hooks with `type: "prompt"` execute Claude prompts; `type: "bash"` runs shell commands
