# Advanced Testing Patterns

## Mocking and Stubbing

### RSpec Mocking

```ruby
# Stubbing methods
allow(PaymentGateway).to receive(:charge).and_return(true)

# Expecting calls
expect(OrderMailer).to receive(:confirmation).with(order).and_call_original

# Stubbing chains
allow(Order).to receive_message_chain(:pending, :recent).and_return([])

# Partial doubles
order = instance_double(Order, total: 100)
```

### Stubbing External Services

```ruby
# spec/support/stripe_helper.rb
module StripeHelper
  def stub_successful_charge
    allow(Stripe::Charge).to receive(:create).and_return(
      OpenStruct.new(id: "ch_test123", status: "succeeded")
    )
  end

  def stub_failed_charge
    allow(Stripe::Charge).to receive(:create).and_raise(
      Stripe::CardError.new("Card declined", "card_declined")
    )
  end
end

RSpec.configure do |config|
  config.include StripeHelper
end
```

### WebMock for HTTP Requests

```ruby
# spec/support/webmock.rb
require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

# Stubbing requests
stub_request(:get, "https://api.example.com/users/1")
  .to_return(
    status: 200,
    body: { id: 1, name: "John" }.to_json,
    headers: { "Content-Type" => "application/json" }
  )

# Matching request body
stub_request(:post, "https://api.example.com/orders")
  .with(body: hash_including(amount: 100))
  .to_return(status: 201)
```

### VCR for Recording HTTP Interactions

```ruby
# spec/support/vcr.rb
VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data("<API_KEY>") { ENV["API_KEY"] }
end

# Usage
RSpec.describe ExternalApiService, :vcr do
  it "fetches user data" do
    result = ExternalApiService.fetch_user(1)
    expect(result[:name]).to eq("John")
  end
end
```

## Time Testing

### Timecop (RSpec)

```ruby
# spec/support/timecop.rb
RSpec.configure do |config|
  config.after(:each) do
    Timecop.return
  end
end

# Usage
it "marks order as expired after 24 hours" do
  order = create(:order, :pending)

  Timecop.travel(25.hours.from_now) do
    expect(order.reload).to be_expired
  end
end
```

### Rails travel_to

```ruby
# Built into Rails
it "marks order as expired after 24 hours" do
  order = create(:order, :pending)

  travel_to 25.hours.from_now do
    expect(order.reload).to be_expired
  end
end

# Freeze time
it "uses current time for created_at" do
  freeze_time do
    order = create(:order)
    expect(order.created_at).to eq(Time.current)
  end
end
```

## Testing Background Jobs

### Testing Job Enqueueing

```ruby
it "enqueues confirmation email job" do
  expect {
    OrderService.create(params)
  }.to have_enqueued_job(OrderMailer.delivery_job)
    .with("confirmation", order.id)
    .on_queue("mailers")
end
```

### Testing Job Execution

```ruby
it "processes order correctly" do
  order = create(:order, :pending)

  perform_enqueued_jobs do
    OrderProcessingJob.perform_later(order.id)
  end

  expect(order.reload.status).to eq("processing")
end
```

### Inline Job Execution

```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.around(:each, :perform_jobs) do |example|
    perform_enqueued_jobs { example.run }
  end
end

# Usage
it "sends confirmation email", :perform_jobs do
  OrderService.create(params)
  expect(ActionMailer::Base.deliveries.size).to eq(1)
end
```

## Testing Mailers

```ruby
# spec/mailers/order_mailer_spec.rb
RSpec.describe OrderMailer, type: :mailer do
  describe "#confirmation" do
    let(:order) { create(:order) }
    let(:mail) { described_class.confirmation(order) }

    it "renders the headers" do
      expect(mail.subject).to eq("Order Confirmation ##{order.number}")
      expect(mail.to).to eq([order.user.email])
      expect(mail.from).to eq(["orders@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include(order.number)
      expect(mail.body.encoded).to include(order.total.to_s)
    end
  end
end
```

## Testing ActionCable

```ruby
# spec/channels/notifications_channel_spec.rb
RSpec.describe NotificationsChannel, type: :channel do
  let(:user) { create(:user) }

  before do
    stub_connection current_user: user
  end

  it "subscribes to user stream" do
    subscribe

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(user)
  end

  it "broadcasts notifications" do
    subscribe

    expect {
      NotificationsChannel.broadcast_to(user, message: "Hello")
    }.to have_broadcasted_to(user).with(message: "Hello")
  end
end
```

## Testing File Uploads

### ActiveStorage

```ruby
it "attaches avatar" do
  user = create(:user)
  file = fixture_file_upload("avatar.png", "image/png")

  patch user_path(user), params: { user: { avatar: file } }

  expect(user.reload.avatar).to be_attached
end
```

### Direct Upload Testing

```ruby
it "creates blob for direct upload" do
  post rails_direct_uploads_path, params: {
    blob: {
      filename: "avatar.png",
      byte_size: 1024,
      checksum: Digest::MD5.base64digest("content"),
      content_type: "image/png"
    }
  }

  expect(response).to have_http_status(:created)
  expect(ActiveStorage::Blob.count).to eq(1)
end
```

## Contract Testing

### Using JSON Schema

```ruby
# spec/support/json_schemas/order.json
{
  "type": "object",
  "required": ["id", "status", "total"],
  "properties": {
    "id": { "type": "integer" },
    "status": { "type": "string", "enum": ["pending", "completed"] },
    "total": { "type": "string", "pattern": "^\\d+\\.\\d{2}$" }
  }
}

# spec/support/json_schema_matcher.rb
RSpec::Matchers.define :match_json_schema do |schema|
  match do |response|
    schema_path = Rails.root.join("spec/support/json_schemas", "#{schema}.json")
    JSON::Validator.validate!(schema_path.to_s, response.body, strict: true)
  end
end

# Usage
it "returns valid order JSON" do
  get order_path(order)
  expect(response).to match_json_schema("order")
end
```

## Testing Concerns

```ruby
# spec/models/concerns/searchable_spec.rb
RSpec.describe Searchable do
  let(:model_class) do
    Class.new(ApplicationRecord) do
      self.table_name = "products"
      include Searchable
      searchable_fields :name, :description
    end
  end

  it "searches across fields" do
    create_products_for_test

    results = model_class.search("widget")
    expect(results).to include(product_with_widget_name)
    expect(results).to include(product_with_widget_description)
  end
end
```

## Testing Turbo Streams

```ruby
# spec/requests/orders_spec.rb
it "returns turbo stream for create" do
  post orders_path, params: valid_params,
       headers: { "Accept" => "text/vnd.turbo-stream.html" }

  expect(response.content_type).to include("text/vnd.turbo-stream.html")
  expect(response.body).to include('turbo-stream action="append"')
  expect(response.body).to include("orders")
end
```

## Custom Matchers

```ruby
# spec/support/matchers/have_error_on.rb
RSpec::Matchers.define :have_error_on do |attribute|
  match do |record|
    record.valid?
    record.errors[attribute].present?
  end

  chain :with_message do |message|
    @message = message
  end

  match do |record|
    record.valid?
    errors = record.errors[attribute]
    return false if errors.empty?
    return errors.any? { |e| e.include?(@message) } if @message

    true
  end
end

# Usage
expect(order).to have_error_on(:total).with_message("must be positive")
```

## Test Data Patterns

### Traits for States

```ruby
FactoryBot.define do
  factory :order do
    trait :pending do
      status { :pending }
    end

    trait :paid do
      status { :paid }
      paid_at { Time.current }
      after(:create) { |o| create(:payment, :successful, order: o) }
    end

    trait :shipped do
      paid
      status { :shipped }
      shipped_at { Time.current }
    end
  end
end

# Clear test setup
create(:order, :shipped)
```

### Sequences

```ruby
FactoryBot.define do
  sequence(:email) { |n| "user#{n}@example.com" }
  sequence(:order_number) { |n| "ORD-#{n.to_s.rjust(6, '0')}" }

  factory :user do
    email
  end

  factory :order do
    order_number
  end
end
```

## Coverage Configuration

```ruby
# spec/spec_helper.rb
require "simplecov"
SimpleCov.start "rails" do
  add_filter "/spec/"
  add_filter "/config/"
  add_filter "/vendor/"

  add_group "Services", "app/services"
  add_group "Serializers", "app/serializers"

  minimum_coverage 90
  minimum_coverage_by_file 80
end
```
