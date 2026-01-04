# Overengineering Patterns to Avoid

Common patterns that add unnecessary complexity without proportional value.

## The YAGNI Principle

**You Aren't Gonna Need It**

Be aggressive about cutting features:

| Situation | Action |
|-----------|--------|
| Unsure if needed | Cut it |
| For "future flexibility" | Cut it |
| Only 20% of users need it | Cut it |
| Adds any complexity | Question it, probably cut it |

## Pattern Categories

### 1. Premature Optimization

Building for scale you don't have yet.

**Examples:**

| Spec Says | Reality | Recommendation |
|-----------|---------|----------------|
| "Cache user preferences with Redis" | Accessed once per session | Use in-memory or localStorage |
| "Handle 10,000+ concurrent connections" | Expected: <100 users | Cut entirely, let it fail at scale |
| "Implement connection pooling" | 5 queries per request | Use simple connections |
| "Add CDN for static assets" | 100 daily users | Serve from origin |

**Detection questions:**

- Do we have benchmarks showing this is needed?
- What's the actual expected load?
- What's the cost of optimizing later vs now?

### 2. Feature Creep

Building features nobody asked for.

**Examples:**

| Spec Says | Analysis | Recommendation |
|-----------|----------|----------------|
| "Support 5 export formats (JSON, CSV, XML, YAML, TOML)" | 95% need JSON only | JSON only - YAGNI |
| "Admin panel with role-based access" | Single admin user | Simple password protection |
| "Multi-language support from day 1" | US-only launch | English only, i18n later |
| "Dark mode toggle" | Internal tool | Skip entirely |

**Detection questions:**

- Who asked for this feature?
- How often will it be used?
- What's the cost of adding it later?

### 3. Over-Abstraction

Generic solutions for specific problems.

**Examples:**

| Spec Says | Analysis | Recommendation |
|-----------|----------|----------------|
| "Plugin system for custom validators" | Only 3 validators needed, all known | Implement directly, no plugins |
| "Event-driven architecture with message queue" | Synchronous flow works fine | Direct function calls |
| "Abstract factory for data sources" | Single database, no plans to change | Direct DB access |
| "Microservices architecture" | Single team, simple domain | Monolith |

**Detection questions:**

- How many implementations will this abstraction have?
- Is the abstraction solving a current problem or hypothetical one?
- Would copy-paste be simpler for the actual use cases?

### 4. Infrastructure Overhead

Enterprise solutions for startup problems.

**Examples:**

| Spec Says | Analysis | Recommendation |
|-----------|----------|----------------|
| "Kubernetes deployment with auto-scaling" | Single server handles load | Simple VPS or PaaS |
| "CI/CD with staging, QA, prod environments" | Internal tool, 3 users | Deploy from main branch |
| "Comprehensive monitoring with Datadog/New Relic" | Non-critical batch job | Console logs and email alerts |
| "Database replication with failover" | 99% uptime acceptable | Single instance with backups |

**Detection questions:**

- What's the actual uptime requirement?
- Who will maintain this infrastructure?
- What's the cost vs benefit?

### 5. Testing Extremism

Testing for the sake of metrics.

**Examples:**

| Spec Says | Analysis | Recommendation |
|-----------|----------|----------------|
| "100% code coverage" | Diminishing returns past 80% | Focus on critical paths |
| "Mutation testing for all modules" | Prototype feature | Standard unit tests only |
| "E2E tests for every user flow" | 50+ flows, 2 critical | E2E for critical, unit for rest |
| "Mock every external dependency" | Tests don't catch real issues | Integration tests with real services |

**Detection questions:**

- Do these tests catch real bugs?
- What's the maintenance cost?
- Are we testing behavior or implementation?

## Simplification Recommendations

When reviewing specs, provide:

### 1. Features to Cut

List specific items to remove entirely:

```markdown
**Features to Cut:**
- Multi-language support (English only for MVP)
- Export formats except JSON
- Admin role system (single admin sufficient)
```

### 2. Simpler Alternatives

Suggest replacements:

```markdown
**Simplifications:**
- Instead of Redis caching: Use in-memory Map with TTL
- Instead of message queue: Direct async function calls
- Instead of plugin system: Switch statement with 3 cases
```

### 3. Essential Scope

Define the absolute minimum:

```markdown
**Essential Scope:**
The core problem is X. The minimum solution that solves it:
1. Feature A (required for basic functionality)
2. Feature B (required for usability)
3. Basic error handling

Everything else can be added based on real user feedback.
```

## Red Flags in Specifications

Watch for these phrases that often indicate overengineering:

- "For future flexibility..."
- "In case we need to..."
- "It would be nice to have..."
- "Enterprise-grade..."
- "Scalable to millions of users..."
- "Fully configurable..."
- "Extensible architecture..."
- "Best practices dictate..."

## The Right Amount of Engineering

The goal is **appropriate** engineering:

```
Under-engineering: Technical debt that slows future development
Right-engineering: Solves today's problem simply and clearly
Over-engineering: Complexity for hypothetical future problems
```

**Heuristic**: If you're not sure whether to add something, don't. You can always add it later when you have real evidence it's needed.
