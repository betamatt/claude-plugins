# Zero-Downtime Migration Strategies

## Principles

1. **Never lock tables for extended periods**
2. **Make changes backward compatible**
3. **Deploy code changes before schema changes**
4. **Use online DDL when available**

## Adding Columns

### Safe: Adding Nullable Column

```ruby
class AddNotesToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :notes, :text
    # Nullable by default, no table lock
  end
end
```

### Safe: Adding Column with Default (Rails 7+)

```ruby
class AddStatusToOrders < ActiveRecord::Migration[7.1]
  def change
    # Rails 7+ adds default without locking
    add_column :orders, :status, :string, default: "pending", null: false
  end
end
```

### Unsafe: Changing Existing Column Default

```ruby
# DON'T DO THIS - rewrites entire table
change_column_default :orders, :status, "active"

# DO THIS - add new column, migrate data, drop old
class AddNewStatusToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :new_status, :string, default: "active", null: false
  end
end
# Then migrate data with background job
# Then rename columns in separate migration
```

## Removing Columns

### Step 1: Ignore Column in Code

```ruby
class Order < ApplicationRecord
  self.ignored_columns += ["legacy_field"]
end
```

### Step 2: Deploy Code First

Wait for all application servers to run new code.

### Step 3: Remove Column

```ruby
class RemoveLegacyFieldFromOrders < ActiveRecord::Migration[7.1]
  def change
    remove_column :orders, :legacy_field
  end
end
```

## Adding Indexes

### Concurrent Index Creation

```ruby
class AddIndexToOrdersCreatedAt < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :orders, :created_at, algorithm: :concurrently
  end
end
```

### Important Notes

- Always use `disable_ddl_transaction!`
- Index is built without locking writes
- Takes longer but doesn't block
- If interrupted, clean up invalid index:

```sql
DROP INDEX CONCURRENTLY IF EXISTS index_orders_on_created_at;
```

## Removing Indexes

### Concurrent Index Removal

```ruby
class RemoveOldIndexFromOrders < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    remove_index :orders, :old_column, algorithm: :concurrently
  end
end
```

## Renaming Tables/Columns

### Never Rename Directly

```ruby
# DON'T DO THIS
rename_table :orders, :purchases
rename_column :orders, :status, :state
```

### Safe Rename Pattern

**Step 1: Add new column**
```ruby
class AddStateToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :state, :string
  end
end
```

**Step 2: Write to both columns**
```ruby
class Order < ApplicationRecord
  before_save :sync_state

  def sync_state
    self.state = status if status_changed?
    self.status = state if state_changed?
  end
end
```

**Step 3: Backfill data**
```ruby
class BackfillOrderState < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    Order.in_batches do |batch|
      batch.update_all("state = status")
    end
  end
end
```

**Step 4: Update code to use new column**

**Step 5: Remove old column**
```ruby
class RemoveStatusFromOrders < ActiveRecord::Migration[7.1]
  def change
    remove_column :orders, :status
  end
end
```

## Changing Column Types

### Safe Type Conversions

```ruby
# String to text (safe, no rewrite)
change_column :orders, :notes, :text

# Integer to bigint (PostgreSQL 11+, safe)
change_column :orders, :quantity, :bigint
```

### Unsafe Type Conversions

Changing varchar length, string to integer, etc. requires the add-migrate-remove pattern.

## Adding Foreign Keys

### With Validation (Locks Table)

```ruby
add_foreign_key :orders, :users
# Validates all existing data - can lock table
```

### Without Validation (Faster)

```ruby
class AddForeignKeyOrdersUsers < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :orders, :users, validate: false
  end
end

class ValidateForeignKeyOrdersUsers < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :orders, :users
  end
end
```

## Adding NOT NULL Constraints

### PostgreSQL 12+ (Safe)

```ruby
class AddNotNullToOrderStatus < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :orders, "status IS NOT NULL", name: "orders_status_null", validate: false
    validate_check_constraint :orders, name: "orders_status_null"
    change_column_null :orders, :status, false
    remove_check_constraint :orders, name: "orders_status_null"
  end
end
```

### Pre-PostgreSQL 12

```ruby
# Step 1: Add check constraint
add_check_constraint :orders, "status IS NOT NULL", name: "orders_status_null", validate: false

# Step 2: Validate in separate migration
validate_check_constraint :orders, name: "orders_status_null"

# Step 3: Add NOT NULL (instant after constraint validated)
change_column_null :orders, :status, false
```

## Large Data Migrations

### Background Jobs

```ruby
class BackfillOrderTotals < ActiveRecord::Migration[7.1]
  def up
    # Schedule job instead of running inline
    BackfillOrderTotalsJob.perform_later
  end
end

class BackfillOrderTotalsJob < ApplicationJob
  def perform
    Order.where(total_cents: nil).find_each do |order|
      order.update_column(:total_cents, order.calculate_total_cents)
    end
  end
end
```

### Batched Updates

```ruby
class BackfillInBatches < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    Order.in_batches(of: 10_000) do |batch|
      batch.update_all("total_cents = total * 100")
      sleep(0.1) # Reduce load
    end
  end
end
```

## Using strong_migrations Gem

```ruby
# Gemfile
gem "strong_migrations"

# config/initializers/strong_migrations.rb
StrongMigrations.start_after = 20231201000000

# Catches unsafe migrations
class AddIndexUnsafely < ActiveRecord::Migration[7.1]
  def change
    add_index :orders, :user_id
    # ERROR: Adding an index non-concurrently locks the table
  end
end
```

## Rollback Strategies

### Reversible Migrations

```ruby
class AddStateToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :state, :string, default: "pending"
    # Automatically reversible
  end
end
```

### Irreversible with Safety Net

```ruby
class RemoveOldData < ActiveRecord::Migration[7.1]
  def up
    # Create backup table first
    execute "CREATE TABLE orders_backup_#{Time.current.to_i} AS SELECT * FROM orders WHERE archived = true"
    Order.where(archived: true).delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Data was deleted. Restore from backup table."
  end
end
```

## Deployment Order Checklist

1. **Before deploy**: Create backward-compatible migration
2. **Deploy**: New code with column ignored if removing
3. **Run migration**: Add/remove columns
4. **If adding**: Deploy code that uses new column
5. **If removing**: Migration already ran, done

## Common Gotchas

### Lock Timeouts

```ruby
# Set lock timeout for migration
class AddIndexSafely < ActiveRecord::Migration[7.1]
  def change
    execute "SET lock_timeout = '5s'"
    add_index :orders, :user_id, algorithm: :concurrently
  end
end
```

### Statement Timeouts

```ruby
# For long-running migrations
class LongMigration < ActiveRecord::Migration[7.1]
  def change
    execute "SET statement_timeout = '1h'"
    # Long operation
  end
end
```

### Testing Migrations

```ruby
# spec/migrations/add_status_to_orders_spec.rb
require "rails_helper"
require_migration "add_status_to_orders"

RSpec.describe AddStatusToOrders do
  it "adds status column with default" do
    migrate

    expect(Order.column_names).to include("status")
    expect(Order.columns_hash["status"].default).to eq("pending")
  end
end
```
