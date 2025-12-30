# Rails API Conventions

## API Versioning

### URL Versioning (Recommended)

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :orders
      resources :products
    end

    namespace :v2 do
      resources :orders
    end
  end
end
```

### Controller Structure

```ruby
# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_api_user!

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

      private

      def authenticate_api_user!
        @current_api_user = User.find_by(api_token: bearer_token)
        render_unauthorized unless @current_api_user
      end

      def bearer_token
        request.headers["Authorization"]&.split(" ")&.last
      end

      def not_found
        render json: { error: "Not found" }, status: :not_found
      end

      def unprocessable_entity(exception)
        render json: { errors: exception.record.errors.full_messages },
               status: :unprocessable_entity
      end

      def render_unauthorized
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end
  end
end
```

## JSON Serialization

### Using ActiveModel Serializers

```ruby
# app/serializers/order_serializer.rb
class OrderSerializer < ActiveModel::Serializer
  attributes :id, :status, :total, :created_at

  has_many :line_items
  belongs_to :user

  def total
    object.total.to_s
  end
end
```

### Using Blueprinter

```ruby
# app/blueprints/order_blueprint.rb
class OrderBlueprint < Blueprinter::Base
  identifier :id

  fields :status, :created_at

  field :total do |order|
    order.total.to_s
  end

  association :line_items, blueprint: LineItemBlueprint
  association :user, blueprint: UserBlueprint

  view :detailed do
    association :payments, blueprint: PaymentBlueprint
    field :audit_log do |order|
      order.versions.map { |v| { action: v.event, at: v.created_at } }
    end
  end
end

# Usage
OrderBlueprint.render(order)
OrderBlueprint.render(order, view: :detailed)
```

### Using JBuilder

```ruby
# app/views/api/v1/orders/show.json.jbuilder
json.order do
  json.id @order.id
  json.status @order.status
  json.total @order.total.to_s
  json.created_at @order.created_at.iso8601

  json.line_items @order.line_items do |item|
    json.id item.id
    json.product_name item.product.name
    json.quantity item.quantity
    json.price item.price.to_s
  end

  json.user do
    json.id @order.user.id
    json.email @order.user.email
  end
end
```

## Authentication Patterns

### API Token Authentication

```ruby
class User < ApplicationRecord
  has_secure_token :api_token

  def regenerate_api_token!
    regenerate_api_token
    save!
  end
end
```

### JWT Authentication

```ruby
# app/services/jwt_service.rb
class JwtService
  SECRET = Rails.application.credentials.jwt_secret!
  ALGORITHM = "HS256"

  def self.encode(payload, exp: 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET, ALGORITHM)
  end

  def self.decode(token)
    JWT.decode(token, SECRET, true, algorithm: ALGORITHM).first
  rescue JWT::DecodeError
    nil
  end
end
```

### OAuth2 with Doorkeeper

```ruby
# config/initializers/doorkeeper.rb
Doorkeeper.configure do
  orm :active_record

  resource_owner_authenticator do
    current_user || redirect_to(new_session_url)
  end

  access_token_expires_in 2.hours
  use_refresh_token
end
```

## Response Patterns

### Standard JSON Response

```ruby
module Api
  module V1
    class OrdersController < BaseController
      def index
        orders = Order.where(user: current_api_user)
                     .includes(:line_items)
                     .page(params[:page])
                     .per(params[:per_page] || 25)

        render json: {
          orders: OrderBlueprint.render_as_hash(orders),
          meta: {
            current_page: orders.current_page,
            total_pages: orders.total_pages,
            total_count: orders.total_count
          }
        }
      end

      def show
        order = current_api_user.orders.find(params[:id])
        render json: { order: OrderBlueprint.render_as_hash(order, view: :detailed) }
      end

      def create
        order = Orders::CreateService.new(
          user: current_api_user,
          params: order_params
        ).call

        render json: { order: OrderBlueprint.render_as_hash(order) },
               status: :created
      end
    end
  end
end
```

### Error Response Format

```ruby
# Consistent error format
{
  "error": {
    "code": "validation_failed",
    "message": "Order could not be created",
    "details": [
      { "field": "shipping_address", "message": "can't be blank" },
      { "field": "line_items", "message": "must have at least one item" }
    ]
  }
}

# Implementation
def render_error(code:, message:, details: [], status: :unprocessable_entity)
  render json: {
    error: {
      code: code,
      message: message,
      details: details
    }
  }, status: status
end
```

## Rate Limiting

### Using Rack::Attack

```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  # Throttle API requests by IP
  throttle("api/ip", limit: 300, period: 5.minutes) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  # Throttle API requests by token
  throttle("api/token", limit: 1000, period: 1.hour) do |req|
    if req.path.start_with?("/api/")
      req.env["HTTP_AUTHORIZATION"]&.split(" ")&.last
    end
  end

  # Stricter throttle for authentication endpoints
  throttle("api/auth", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/api/v1/auth" && req.post?
  end

  self.throttled_responder = lambda do |env|
    retry_after = (env["rack.attack.match_data"] || {})[:period]
    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s
      },
      [{ error: { code: "rate_limited", message: "Too many requests" } }.to_json]
    ]
  end
end
```

## API Documentation

### Using RSwag with RSpec

```ruby
# spec/requests/api/v1/orders_spec.rb
require "swagger_helper"

RSpec.describe "Orders API", type: :request do
  path "/api/v1/orders" do
    get "List orders" do
      tags "Orders"
      produces "application/json"
      security [bearer_auth: []]

      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response "200", "orders found" do
        schema type: :object,
          properties: {
            orders: { type: :array, items: { "$ref" => "#/components/schemas/Order" } },
            meta: { "$ref" => "#/components/schemas/Pagination" }
          }

        run_test!
      end

      response "401", "unauthorized" do
        run_test!
      end
    end
  end
end
```

## Pagination

### Using Kaminari

```ruby
# Controller
orders = Order.page(params[:page]).per(25)

# Response
{
  "orders": [...],
  "meta": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 10,
    "total_count": 250
  },
  "links": {
    "self": "/api/v1/orders?page=1",
    "next": "/api/v1/orders?page=2",
    "last": "/api/v1/orders?page=10"
  }
}
```

### Cursor-based Pagination

```ruby
# For large datasets
def index
  orders = Order.where("id > ?", params[:cursor].to_i)
                .order(:id)
                .limit(25)

  render json: {
    orders: OrderBlueprint.render_as_hash(orders),
    meta: {
      next_cursor: orders.last&.id,
      has_more: orders.size == 25
    }
  }
end
```
