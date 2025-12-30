---
name: Rails Testing
description: This skill should be used when the user asks about "Rails testing", "RSpec", "Minitest", "request specs", "system specs", "FactoryBot", "fixtures", "test coverage", "testing controllers", "testing models", "integration tests", or needs guidance on writing effective tests for Rails 7+ applications.
version: 1.0.0
---

# Rails Testing for Production Systems

Production-focused testing guidance supporting both RSpec and Minitest. Detect the project's testing framework and apply appropriate patterns.

## Framework Detection

Check for testing framework in use:

```bash
# RSpec if present
grep -q "rspec-rails" Gemfile && echo "RSpec"

# Check for spec directory
ls -d spec 2>/dev/null && echo "RSpec"

# Minitest (Rails default)
ls -d test 2>/dev/null && echo "Minitest"
```

## RSpec Patterns

### Directory Structure

```
spec/
├── factories/           # FactoryBot definitions
├── fixtures/files/      # File fixtures (images, PDFs)
├── models/              # Model specs
├── requests/            # Request specs (API testing)
├── services/            # Service object specs
├── system/              # System specs (browser testing)
├── support/             # Helpers, shared examples
│   ├── factory_bot.rb
│   ├── capybara.rb
│   └── shared_examples/
└── rails_helper.rb
```

### Request Specs (API Testing)

```ruby
# spec/requests/api/v1/orders_spec.rb
RSpec.describe "Orders API", type: :request do
  let(:user) { create(:user) }
  let(:headers) { { "Authorization" => "Bearer #{user.api_token}" } }

  describe "GET /api/v1/orders" do
    let!(:orders) { create_list(:order, 3, user: user) }

    it "returns user orders" do
      get "/api/v1/orders", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response["orders"].size).to eq(3)
    end

    it "excludes other users orders" do
      other_order = create(:order)

      get "/api/v1/orders", headers: headers

      expect(json_response["orders"].map { |o| o["id"] })
        .not_to include(other_order.id)
    end
  end

  describe "POST /api/v1/orders" do
    let(:valid_params) do
      {
        order: {
          shipping_address_id: create(:address, user: user).id,
          line_items_attributes: [
            { product_id: create(:product).id, quantity: 2 }
          ]
        }
      }
    end

    it "creates an order" do
      expect {
        post "/api/v1/orders", params: valid_params, headers: headers
      }.to change(Order, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    context "with invalid params" do
      it "returns validation errors" do
        post "/api/v1/orders",
             params: { order: { line_items_attributes: [] } },
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["errors"]).to include(/line items/i)
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
```

### Model Specs

```ruby
# spec/models/order_spec.rb
RSpec.describe Order, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:status) }

    it "requires at least one line item" do
      order = build(:order, line_items: [])
      expect(order).not_to be_valid
      expect(order.errors[:line_items]).to include("can't be empty")
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:line_items).dependent(:destroy) }
    it { is_expected.to have_many(:products).through(:line_items) }
  end

  describe "scopes" do
    describe ".pending" do
      it "returns only pending orders" do
        pending = create(:order, :pending)
        completed = create(:order, :completed)

        expect(Order.pending).to include(pending)
        expect(Order.pending).not_to include(completed)
      end
    end
  end

  describe "#total" do
    it "calculates sum of line item totals" do
      order = create(:order)
      create(:line_item, order: order, price: 10, quantity: 2)
      create(:line_item, order: order, price: 5, quantity: 1)

      expect(order.total).to eq(25)
    end
  end
end
```

### System Specs (Browser Testing)

```ruby
# spec/system/checkout_spec.rb
RSpec.describe "Checkout", type: :system do
  let(:user) { create(:user) }
  let(:product) { create(:product, name: "Widget", price: 99) }

  before do
    sign_in user
    create(:cart_item, user: user, product: product, quantity: 2)
  end

  it "completes checkout successfully" do
    visit cart_path

    expect(page).to have_content("Widget")
    expect(page).to have_content("$198.00")

    click_on "Proceed to Checkout"

    fill_in "Street address", with: "123 Main St"
    fill_in "City", with: "Portland"
    select "Oregon", from: "State"
    fill_in "Zip", with: "97201"

    click_on "Place Order"

    expect(page).to have_content("Order confirmed")
    expect(page).to have_content("Order #")
  end

  it "shows validation errors for invalid address" do
    visit checkout_path

    click_on "Place Order"

    expect(page).to have_content("Street address can't be blank")
  end
end
```

### FactoryBot Patterns

```ruby
# spec/factories/orders.rb
FactoryBot.define do
  factory :order do
    user
    status { :pending }

    transient do
      items_count { 1 }
    end

    after(:build) do |order, evaluator|
      if order.line_items.empty?
        evaluator.items_count.times do
          order.line_items << build(:line_item, order: order)
        end
      end
    end

    trait :pending do
      status { :pending }
    end

    trait :completed do
      status { :completed }
      completed_at { Time.current }
    end

    trait :with_payment do
      after(:create) do |order|
        create(:payment, order: order)
      end
    end
  end
end
```

### Shared Examples

```ruby
# spec/support/shared_examples/authenticatable.rb
RSpec.shared_examples "requires authentication" do
  context "without authentication" do
    let(:headers) { {} }

    it "returns unauthorized" do
      make_request
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

# Usage
RSpec.describe "Orders API" do
  describe "GET /api/v1/orders" do
    it_behaves_like "requires authentication" do
      let(:make_request) { get "/api/v1/orders", headers: headers }
    end
  end
end
```

## Minitest Patterns

### Directory Structure

```
test/
├── fixtures/            # YAML fixtures
├── controllers/         # Functional tests
├── integration/         # Integration tests
├── models/              # Unit tests
├── system/              # System tests
├── helpers/             # Helper tests
└── test_helper.rb
```

### Model Tests

```ruby
# test/models/order_test.rb
class OrderTest < ActiveSupport::TestCase
  test "validates presence of user" do
    order = Order.new(user: nil)
    assert_not order.valid?
    assert_includes order.errors[:user], "must exist"
  end

  test "calculates total correctly" do
    order = orders(:pending_order)
    assert_equal 150, order.total
  end

  test "scope pending returns only pending orders" do
    pending_orders = Order.pending
    assert pending_orders.all? { |o| o.status == "pending" }
  end
end
```

### Controller Tests (Integration)

```ruby
# test/controllers/orders_controller_test.rb
class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:john)
    sign_in @user
  end

  test "should get index" do
    get orders_url
    assert_response :success
    assert_select "h1", "Your Orders"
  end

  test "should create order" do
    assert_difference("Order.count") do
      post orders_url, params: {
        order: {
          shipping_address_id: addresses(:home).id,
          line_items_attributes: [
            { product_id: products(:widget).id, quantity: 1 }
          ]
        }
      }
    end

    assert_redirected_to order_url(Order.last)
  end
end
```

### System Tests

```ruby
# test/system/checkouts_test.rb
class CheckoutsTest < ApplicationSystemTestCase
  setup do
    @user = users(:john)
    sign_in @user
    @cart = create_cart_with_items(@user)
  end

  test "completing checkout" do
    visit cart_url

    click_on "Checkout"

    fill_in "Street address", with: "123 Main St"
    fill_in "City", with: "Portland"
    click_on "Place Order"

    assert_text "Order confirmed"
  end
end
```

### Fixtures

```yaml
# test/fixtures/orders.yml
pending_order:
  user: john
  status: pending
  created_at: <%= 1.day.ago %>

completed_order:
  user: john
  status: completed
  completed_at: <%= 1.hour.ago %>
```

## Testing Best Practices

### Test Speed

```ruby
# Use build instead of create when possible
order = build(:order)  # No database hit
order = create(:order) # Database hit

# Use build_stubbed for even faster tests
order = build_stubbed(:order)

# Disable callbacks when not needed
user = create(:user, :skip_callbacks)
```

### Database Cleaner

```ruby
# spec/support/database_cleaner.rb
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :system) do
    DatabaseCleaner.strategy = :truncation
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning { example.run }
  end
end
```

### Parallel Testing

```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.before(:suite) do
    # Prepare database for parallel testing
    ActiveRecord::Base.connection.execute("SET SESSION lock_timeout = '2s'")
  end
end

# Run tests in parallel
# PARALLEL_TEST_PROCESSORS=4 bundle exec rspec
```

## Additional Resources

### Reference Files

For detailed patterns and examples:
- **`references/testing-patterns.md`** - Advanced testing patterns, mocking, time testing
- **`references/ci-configuration.md`** - GitHub Actions, parallel testing setup
