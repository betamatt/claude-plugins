# Ruby on Rails Plugin for Claude Code

A professional Ruby on Rails development toolkit designed for senior engineers building production systems. This plugin provides proactive expert assistance, smart generators, and Rails 7+ best practices.

## Features

### Proactive Agents

- **rails-expert** - General Rails development assistance, automatically activates in Rails projects
- **migration-expert** - Safe database migration strategies and schema design
- **performance-expert** - Detects N+1 queries, suggests eager loading and query optimization
- **security-expert** - Identifies real security vulnerabilities (pragmatic, not noisy)

### Skills (Auto-activating)

- **rails-conventions** - Rails 7+ naming, structure, Hotwire patterns
- **activerecord-patterns** - Query optimization, associations, modern ActiveRecord
- **rails-testing** - RSpec and Minitest patterns, factories, request specs

### Commands

- `/rails:generate` - Smart generators with production-ready defaults
- `/rails:migrate` - Safe migration workflow with rollback strategies
- `/rails:db` - Database operations (seed, reset, prepare)

## Requirements

- Ruby 3.1+
- Rails 7.0+
- Claude Code CLI

## Installation

```bash
# From marketplace
claude plugins install ruby-on-rails

# Or local development
claude --plugin-dir /path/to/ruby-on-rails
```

## Usage

The plugin automatically detects Rails projects and activates relevant context. Agents will proactively suggest improvements when they detect issues.

### Examples

```bash
# In a Rails project, Claude will automatically use Rails conventions
claude "add a User model with email and name"

# Use commands for specific operations
/rails:generate model Post title:string body:text published:boolean

# Agents activate when relevant
claude "optimize this controller action"  # performance-expert activates
claude "review this authentication code"  # security-expert activates
```

## Testing Support

The plugin detects your testing framework automatically:

- **RSpec**: Supports request specs, system specs, FactoryBot
- **Minitest**: Supports fixtures, integration tests

## Plugin Structure

```
ruby-on-rails/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── agents/
│   ├── rails-expert.md      # General Rails development
│   ├── migration-expert.md  # Database migrations
│   ├── performance-expert.md # Query optimization
│   └── security-expert.md   # Security review
├── commands/
│   ├── generate.md          # /rails:generate
│   ├── migrate.md           # /rails:migrate
│   └── db.md                # /rails:db
├── hooks/
│   └── hooks.json           # SessionStart hook for Rails detection
├── skills/
│   ├── rails-conventions/   # Naming, structure, Hotwire
│   ├── activerecord-patterns/ # Queries, associations
│   └── rails-testing/       # RSpec, Minitest patterns
└── README.md
```

## How It Works

### Automatic Rails Detection

When you start Claude Code in a directory containing a Gemfile with Rails, the SessionStart hook automatically detects the Rails version and key gems, activating Rails-specific context.

### Proactive Agents

Agents don't just respond to requests—they proactively detect when they can help:

- **performance-expert**: Notices N+1 query patterns in your code
- **security-expert**: Flags potential vulnerabilities in authentication code
- **migration-expert**: Suggests safe migration patterns for schema changes

### Skills Auto-Loading

Skills load based on context:

- Ask about "naming conventions" → rails-conventions skill activates
- Work with "database queries" → activerecord-patterns skill activates
- Mention "testing" or "specs" → rails-testing skill activates

## License

MIT
