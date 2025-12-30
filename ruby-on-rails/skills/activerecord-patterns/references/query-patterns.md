# Advanced Query Patterns

## Common Table Expressions (CTEs)

Rails 7.1+ supports CTEs natively:

```ruby
# Recursive CTE for hierarchical data
class Category < ApplicationRecord
  def self.with_descendants(root_id)
    with_recursive(
      categories_tree: [
        Category.where(id: root_id),
        Category.joins("INNER JOIN categories_tree ON categories.parent_id = categories_tree.id")
      ]
    ).from("categories_tree AS categories")
  end
end

# Usage
Category.with_descendants(1).pluck(:name)
```

## Window Functions

```ruby
# Rank orders by total within each user
Order.select(
  "orders.*",
  "RANK() OVER (PARTITION BY user_id ORDER BY total DESC) as user_rank"
).where("total > ?", 100)

# Running total
Order.select(
  "orders.*",
  "SUM(total) OVER (ORDER BY created_at) as running_total"
)

# Moving average
Order.select(
  "orders.*",
  "AVG(total) OVER (ORDER BY created_at ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as weekly_avg"
)
```

## Subqueries

### In SELECT

```ruby
# Include aggregated data
Order.select(
  "orders.*",
  "(SELECT COUNT(*) FROM line_items WHERE line_items.order_id = orders.id) as items_count"
)
```

### In WHERE

```ruby
# Orders with above-average totals
avg_subquery = Order.select("AVG(total)")
Order.where("total > (#{avg_subquery.to_sql})")

# Using Arel
Order.where(
  Order.arel_table[:total].gt(
    Order.select(Order.arel_table[:total].average)
  )
)
```

### Lateral Joins

```ruby
# Get latest order for each user (PostgreSQL)
User.select("users.*, latest_order.*")
    .joins(
      "LEFT JOIN LATERAL (
        SELECT * FROM orders
        WHERE orders.user_id = users.id
        ORDER BY created_at DESC
        LIMIT 1
      ) AS latest_order ON true"
    )
```

## JSON Queries (PostgreSQL)

### Querying JSONB Columns

```ruby
class Product < ApplicationRecord
  # metadata is a JSONB column

  scope :with_feature, ->(feature) {
    where("metadata -> 'features' ? ?", feature)
  }

  scope :by_spec, ->(key, value) {
    where("metadata -> 'specs' ->> ? = ?", key, value)
  }

  scope :color, ->(color) {
    where("metadata @> ?", { color: color }.to_json)
  }
end

# Complex JSON queries
Product.where("metadata #>> '{dimensions,width}' > ?", "10")
Product.where("jsonb_array_length(metadata -> 'images') > ?", 3)
```

### JSON Aggregation

```ruby
# Aggregate into JSON array
Order.select(
  "users.id",
  "users.email",
  "JSON_AGG(orders.* ORDER BY orders.created_at DESC) as recent_orders"
).joins(:user)
 .group("users.id")
```

## Full-Text Search (PostgreSQL)

```ruby
class Article < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search,
    against: {
      title: 'A',
      body: 'B',
      tags: 'C'
    },
    using: {
      tsearch: {
        dictionary: 'english',
        prefix: true,
        any_word: true
      },
      trigram: {
        threshold: 0.3
      }
    }
end

# Raw tsvector query
Article.where(
  "to_tsvector('english', title || ' ' || body) @@ plainto_tsquery('english', ?)",
  search_term
)
```

## Upsert Operations

### PostgreSQL Upsert

```ruby
# Rails 7+ native upsert
Order.upsert(
  { order_number: "ORD-001", status: "pending", total: 100 },
  unique_by: :order_number
)

# Bulk upsert
Order.upsert_all(
  [
    { order_number: "ORD-001", status: "shipped" },
    { order_number: "ORD-002", status: "pending" }
  ],
  unique_by: :order_number,
  update_only: [:status]
)
```

### With Conflict Resolution

```ruby
# Custom conflict handling
Order.upsert(
  { order_number: "ORD-001", total: 150 },
  unique_by: :order_number,
  on_duplicate: Arel.sql("total = EXCLUDED.total + orders.total")
)
```

## Materialized Views

### Creating Materialized Views

```ruby
class CreateOrderSummaryView < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      CREATE MATERIALIZED VIEW order_summaries AS
      SELECT
        users.id as user_id,
        COUNT(orders.id) as order_count,
        SUM(orders.total) as total_spent,
        MAX(orders.created_at) as last_order_at
      FROM users
      LEFT JOIN orders ON orders.user_id = users.id
      WHERE orders.status = 'completed'
      GROUP BY users.id
      WITH DATA;

      CREATE UNIQUE INDEX ON order_summaries (user_id);
    SQL
  end

  def down
    execute "DROP MATERIALIZED VIEW order_summaries"
  end
end
```

### Refreshing Views

```ruby
class OrderSummary < ApplicationRecord
  self.table_name = "order_summaries"

  def self.refresh
    connection.execute("REFRESH MATERIALIZED VIEW CONCURRENTLY order_summaries")
  end
end

# Periodic refresh
class RefreshOrderSummariesJob < ApplicationJob
  def perform
    OrderSummary.refresh
  end
end
```

## Query Objects Pattern

### Basic Query Object

```ruby
class Orders::PendingWithHighValueQuery
  def initialize(relation = Order.all)
    @relation = relation
  end

  def call(min_value: 100)
    @relation
      .where(status: :pending)
      .where("total > ?", min_value)
      .includes(:user, :line_items)
      .order(created_at: :desc)
  end
end

# Usage
Orders::PendingWithHighValueQuery.new.call(min_value: 500)
Orders::PendingWithHighValueQuery.new(current_user.orders).call
```

### Composable Query Objects

```ruby
class Orders::SearchQuery
  def initialize(relation = Order.all)
    @relation = relation
  end

  def call(params)
    result = @relation

    result = by_status(result, params[:status]) if params[:status].present?
    result = by_date_range(result, params[:from], params[:to]) if params[:from].present?
    result = by_search_term(result, params[:q]) if params[:q].present?
    result = by_min_total(result, params[:min_total]) if params[:min_total].present?

    result.order(created_at: :desc)
  end

  private

  def by_status(relation, status)
    relation.where(status: status)
  end

  def by_date_range(relation, from, to)
    relation.where(created_at: from..to)
  end

  def by_search_term(relation, term)
    relation.where("order_number ILIKE ? OR notes ILIKE ?", "%#{term}%", "%#{term}%")
  end

  def by_min_total(relation, min)
    relation.where("total >= ?", min)
  end
end
```

## Performance Monitoring

### Query Logging

```ruby
# config/initializers/query_logger.rb
ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  if event.duration > 100 # ms
    Rails.logger.warn "Slow query (#{event.duration.round(1)}ms): #{event.payload[:sql]}"
  end
end
```

### Explain Analyze

```ruby
# In console
Order.where(status: :pending).explain(:analyze)

# Automatic explain for slow queries
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.verbose_query_logs = true
```
