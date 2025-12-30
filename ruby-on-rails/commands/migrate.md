---
name: migrate
description: Safe migration workflow with production checks
argument-hint: [up|down|redo|status|rollback]
allowed-tools: ["Read", "Bash", "Grep", "Glob"]
---

# Rails Migrate Command

Execute database migrations with safety checks and production awareness.

## Usage

```
/rails:migrate [action]
```

## Actions

- (no argument) - Run pending migrations
- `status` - Show migration status
- `rollback` - Rollback last migration
- `redo` - Rollback and re-run last migration
- `up VERSION=xxx` - Run specific migration up
- `down VERSION=xxx` - Run specific migration down

## Safety Checks

Before running migrations, verify:

1. **Pending migrations exist**
   ```bash
   bin/rails db:migrate:status
   ```

2. **Review migration content**
   - Check for potentially dangerous operations:
     - `remove_column` without `ignored_columns`
     - `change_column` on large tables
     - Non-concurrent index creation
     - `add_column` with `null: false` without default

3. **Check for irreversible migrations**
   - `change_column` without explicit `up`/`down`
   - Data migrations that can't be undone

## Production Warnings

Flag these patterns with warnings:

### Table Locks
```ruby
# WARNING: May lock table
add_index :large_table, :column  # Should use algorithm: :concurrently
change_column :table, :column, :new_type  # May rewrite table
```

### Data Loss
```ruby
# WARNING: Irreversible
remove_column :orders, :status  # Check ignored_columns first
drop_table :old_table  # Ensure data is backed up
```

### Long-Running
```ruby
# WARNING: May take long time
add_column :users, :field, default: "value"  # On large tables
# Rails 7+ handles this efficiently, but warn for older Rails
```

## Process

1. Show migration status
2. List pending migrations with summaries
3. Analyze each migration for safety concerns
4. If concerns found, display warnings
5. Run migrations (or ask for confirmation if concerns)
6. Show results and new schema state

## Rollback Safety

Before rollback:
1. Check if migration is reversible
2. Warn about data that may be lost
3. Suggest alternatives if destructive

## Output

```
Migration Status:
  up     20231201120000  Create users
  up     20231202130000  Add email to users
  down   20231203140000  Add orders table (pending)

Pending Migrations:
  20231203140000_add_orders_table.rb
    - Creates orders table
    - Adds foreign key to users
    - Adds index on user_id

Safety Check: ✓ No concerns found

Running migrations...
  == 20231203140000 AddOrdersTable: migrating ===
  -- create_table(:orders)
  -- add_index(:orders, :user_id)
  == 20231203140000 AddOrdersTable: migrated (0.0123s) ===

✓ Migration complete
```
