---
name: db
description: Database operations - seed, reset, prepare, and more
argument-hint: <seed|reset|prepare|schema:load|schema:dump>
allowed-tools: ["Read", "Bash", "Grep", "Glob"]
---

# Rails Database Command

Execute common database operations with appropriate safeguards.

## Usage

```
/rails:db <action>
```

## Actions

### seed
Run database seeds.
```bash
bin/rails db:seed
```

### reset
Drop, create, migrate, and seed the database.
```bash
bin/rails db:reset
```

**WARNING**: This destroys all data. Only use in development.

### prepare
Prepare database for the current environment (creates if needed, runs migrations).
```bash
bin/rails db:prepare
```

Safe for all environments.

### schema:load
Load schema from `db/schema.rb` (faster than running all migrations).
```bash
bin/rails db:schema:load
```

### schema:dump
Dump current database schema to `db/schema.rb`.
```bash
bin/rails db:schema:dump
```

### setup
Create database, load schema, and seed.
```bash
bin/rails db:setup
```

### create
Create the database.
```bash
bin/rails db:create
```

### drop
Drop the database.
```bash
bin/rails db:drop
```

**WARNING**: Destructive operation.

## Process

1. Identify the requested action
2. Check current environment (development, test, production)
3. For destructive operations:
   - Warn if in production
   - List consequences
   - Require confirmation
4. Execute the command
5. Show results

## Environment Safety

### Development/Test
All operations allowed with standard warnings for destructive actions.

### Production
Restricted operations:
- `reset` - BLOCKED (never reset production)
- `drop` - BLOCKED (manual intervention required)
- `schema:load` - WARNING (destroys existing data)
- `seed` - WARNING (may duplicate data)
- `prepare` - ALLOWED (safe idempotent operation)

## Seed File Best Practices

Recommend idempotent seeds:
```ruby
# db/seeds.rb
# Use find_or_create_by for idempotency
User.find_or_create_by(email: "admin@example.com") do |user|
  user.name = "Admin"
  user.admin = true
end

# Or use upsert for bulk data
Product.upsert_all([
  { sku: "WIDGET-001", name: "Widget", price: 9.99 },
  { sku: "GADGET-001", name: "Gadget", price: 19.99 }
], unique_by: :sku)
```

## Output

```
Action: db:prepare

Environment: development
Database: myapp_development

Checking database status...
  Database exists: ✓
  Pending migrations: 2

Running db:prepare...
  Running migrations...
  == 20231203140000 AddOrdersTable: migrating ===
  == 20231203140000 AddOrdersTable: migrated (0.0123s) ===

✓ Database prepared successfully

Schema version: 20231203140000
Tables: 8
```
