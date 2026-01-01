# Code Review Plugin

Comprehensive code review toolkit with a language-agnostic review methodology. Provides deep, actionable feedback with root cause analysis and working solutions.

## Installation

### From Claude Code Marketplace

```bash
claude plugin add code-review
```

### From Source

```bash
# Clone the plugins repository
git clone https://github.com/anthropics/claude-plugins.git

# Install the code-review plugin
claude plugin add ./claude-plugins/code-review
```

### Manual Installation

Add to your Claude Code settings (`~/.claude/settings.json`):

```json
{
  "plugins": ["code-review"]
}
```

## Quick Start

### Using the Command

```bash
# Review specific files
/code-review src/auth/

# Review recent changes
/code-review --changed

# Focus on a specific aspect
/code-review --focus=security src/api/
```

### Natural Language

The code-reviewer agent activates automatically when you:

```
"Review this code for security issues"
"Check the performance of this module"
"Analyze the architecture of src/services/"
"Do a code review on my recent changes"
```

## Architecture

**Single Agent, Multiple Instances**: One `code-reviewer` agent contains all review expertise. For comprehensive reviews, 6 instances run in parallel, each assigned a different focus area.

## Review Focus Areas

| Focus Area | What It Checks |
|------------|----------------|
| Architecture & Design | Module organization, separation of concerns, design patterns |
| Code Quality | Readability, naming, complexity, DRY principles |
| Security & Dependencies | Vulnerabilities, auth, secrets, supply chain |
| Performance & Scalability | Algorithm complexity, N+1, async patterns |
| Testing Quality | Assertions, isolation, edge cases |
| Documentation & API | README, JSDoc, breaking changes |

## Components

| Type | Name | Purpose |
|------|------|---------|
| Agent | `code-reviewer` | Core review agent (runs multiple instances) |
| Command | `/code-review` | Explicit review invocation |
| Skill | `code-review-patterns` | Methodology and reference patterns |
| Hook | `Stop` | Suggests review after significant changes |

## How It Works

### 1. Context Gathering

When activated, the reviewer first establishes project context:

- **Project Documentation**: Reads CLAUDE.md, README.md, ARCHITECTURE.md
- **Project Structure**: Detects frameworks and architectural patterns
- **Configuration**: Checks for linters, test frameworks, type systems
- **Git Context**: Analyzes changed files and current branch

### 2. Focus Determination

The agent assigns focus based on your request:

| You Say | Focus Selected |
|---------|----------------|
| "security issues" | Security & Dependencies |
| "performance" | Performance & Scalability |
| "code quality" | Code Quality |
| "architecture" | Architecture & Design |
| "test quality" | Testing Quality |
| "documentation" | Documentation & API |

If no specific focus is mentioned, runs all 6 aspects in parallel.

### 3. Root Cause Analysis

For every issue found, provides three levels:

1. **What**: The immediate problem observed
2. **Why**: Root cause analysis explaining why it happens
3. **How**: Working code solution you can apply immediately

### 4. Prioritized Output

Issues are categorized by impact:

| Priority | Criteria | Timeline |
|----------|----------|----------|
| CRITICAL | Security vulnerabilities, data loss, crashes | Immediate |
| HIGH | Performance in hot paths, memory leaks | Before merge |
| MEDIUM | Maintainability, inconsistent patterns | Next sprint |
| LOW | Style, minor optimizations | Backlog |

## Example Output

```markdown
## Security Review: src/auth/

### Health Assessment
- Input Validation: Needs Attention
- Authentication: Good
- Authorization: Critical

### Issues Found

#### [CRITICAL] SQL Injection in User Search
**File:** `src/auth/userSearch.ts:45`
**What:** User input directly concatenated into SQL query
**Why:** The search term flows from request.query to database without sanitization

**Current Code:**
```typescript
const users = await db.query(`SELECT * FROM users WHERE name LIKE '%${term}%'`);
```

**Solution:**
```typescript
const users = await db.query('SELECT * FROM users WHERE name LIKE $1', [`%${term}%`]);
```

### Strengths
- Good session management with secure cookies
- Proper password hashing with bcrypt

### Recommendations
- Add rate limiting to login endpoint
- Consider implementing CSRF protection
```

## FAQ

### Can I review code in any programming language?

Yes. The plugin is language-agnostic and adapts to TypeScript, JavaScript, Python, Ruby, Go, Java, Rust, and more.

### How do I review only specific files?

Specify file paths in your request:

```
/code-review src/auth/login.ts src/auth/session.ts
```

Or use natural language:

```
Review the authentication files in src/auth/
```

### Can I get reviews focused on just one area?

Yes. Use the `--focus` flag or mention the focus area:

```
/code-review --focus=security src/api/
```

Or:

```
Review only the performance aspects of the data processing module
```

### Does it integrate with my existing linters?

The reviewer reads your configuration files (`.eslintrc`, `tsconfig.json`, etc.) to understand project standards. It complements linters by focusing on deeper architectural and logic issues that automated tools miss.

### How do I get more detailed analysis?

Ask for deeper dives:

```
Provide a detailed security audit of the authentication system
Give me an in-depth architectural review with refactoring recommendations
```

### Can it review pull requests automatically?

After completing changes, the plugin suggests running a review via a Stop hook. For CI/CD integration, use the `/code-review --changed` command.

## Priority Levels

| Priority | Criteria | Action |
|----------|----------|--------|
| CRITICAL | Security vulnerabilities, data loss | Fix immediately |
| HIGH | Performance issues, memory leaks | Fix before merge |
| MEDIUM | Maintainability, missing tests | Fix soon |
| LOW | Style, minor improvements | Fix when convenient |

## Why Single Agent?

- **Less duplication**: One file instead of 6
- **Easier maintenance**: Update once, applies everywhere
- **Same parallelism**: Still runs 6 instances concurrently
- **Shared knowledge**: All instances access the same skill

## License

MIT
