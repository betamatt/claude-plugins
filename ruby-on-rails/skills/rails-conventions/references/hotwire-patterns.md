# Advanced Hotwire Patterns

## Turbo Frame Patterns

### Lazy Loading

Load expensive content after initial page render:

```erb
<%= turbo_frame_tag "dashboard_stats", src: dashboard_stats_path, loading: :lazy do %>
  <div class="animate-pulse">Loading stats...</div>
<% end %>
```

### Breaking Out of Frames

Navigate to a full page from within a frame:

```erb
<%= link_to "View Full Details", order_path(@order), data: { turbo_frame: "_top" } %>
```

### Frame Targeting

Update a different frame than the one containing the link:

```erb
<%= turbo_frame_tag "sidebar" %>

<%= turbo_frame_tag "main" do %>
  <%= link_to "Load in Sidebar", sidebar_content_path, data: { turbo_frame: "sidebar" } %>
<% end %>
```

### Nested Frames

```erb
<%= turbo_frame_tag "order_#{order.id}" do %>
  <div class="order">
    <%= render order %>

    <%= turbo_frame_tag "order_#{order.id}_details", src: order_details_path(order) do %>
      <button>Load Details</button>
    <% end %>
  </div>
<% end %>
```

## Turbo Stream Patterns

### Broadcast from Model

```ruby
class Comment < ApplicationRecord
  belongs_to :post

  after_create_commit -> { broadcast_append_to post, :comments }
  after_update_commit -> { broadcast_replace_to post, :comments }
  after_destroy_commit -> { broadcast_remove_to post, :comments }
end
```

### Custom Stream Actions

```erb
<%# Custom flash message %>
<%= turbo_stream.update "flash" do %>
  <%= render "shared/flash", message: "Order created successfully" %>
<% end %>

<%# Update multiple elements %>
<%= turbo_stream.update "cart_count", @cart.items_count %>
<%= turbo_stream.update "cart_total", number_to_currency(@cart.total) %>
```

### Streaming from Background Jobs

```ruby
class OrderStatusJob < ApplicationJob
  def perform(order)
    order.update!(status: :processing)

    Turbo::StreamsChannel.broadcast_replace_to(
      order,
      target: "order_#{order.id}_status",
      partial: "orders/status",
      locals: { order: order }
    )
  end
end
```

### Conditional Streaming

```ruby
def create
  @comment = @post.comments.build(comment_params)

  respond_to do |format|
    if @comment.save
      format.turbo_stream
      format.html { redirect_to @post }
    else
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "new_comment",
          partial: "comments/form",
          locals: { comment: @comment }
        )
      end
      format.html { render :new }
    end
  end
end
```

## Stimulus Patterns

### Controller Communication

Using outlets to connect controllers:

```javascript
// tabs_controller.js
export default class extends Controller {
  static outlets = ["panel"]

  showPanel(event) {
    const panelId = event.currentTarget.dataset.panelId
    this.panelOutlets.forEach(panel => {
      panel.toggle(panel.element.id === panelId)
    })
  }
}

// panel_controller.js
export default class extends Controller {
  static values = { visible: Boolean }

  toggle(show) {
    this.visibleValue = show
  }

  visibleValueChanged() {
    this.element.classList.toggle("hidden", !this.visibleValue)
  }
}
```

### Form Validation

```javascript
// form_validation_controller.js
export default class extends Controller {
  static targets = ["submit", "input"]

  connect() {
    this.validate()
  }

  validate() {
    const valid = this.inputTargets.every(input => input.checkValidity())
    this.submitTarget.disabled = !valid
  }
}
```

### Debounced Search

```javascript
// search_controller.js
import { Controller } from "@hotwired/stimulus"
import { debounce } from "lodash-es"

export default class extends Controller {
  static targets = ["input", "results"]
  static values = { url: String }

  initialize() {
    this.search = debounce(this.search.bind(this), 300)
  }

  search() {
    const query = this.inputTarget.value
    if (query.length < 2) return

    fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
      headers: { "Accept": "text/vnd.turbo-stream.html" }
    })
    .then(response => response.text())
    .then(html => Turbo.renderStreamMessage(html))
  }
}
```

### Modal Controller

```javascript
// modal_controller.js
export default class extends Controller {
  static targets = ["dialog"]
  static values = { open: Boolean }

  open() {
    this.dialogTarget.showModal()
    document.body.classList.add("overflow-hidden")
  }

  close() {
    this.dialogTarget.close()
    document.body.classList.remove("overflow-hidden")
  }

  clickOutside(event) {
    if (event.target === this.dialogTarget) {
      this.close()
    }
  }

  keydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
```

## Morphing (Rails 7.1+)

Enable page refresh without losing scroll position or form state:

```ruby
# Controller
class OrdersController < ApplicationController
  def update
    @order.update(order_params)
    redirect_to @order, status: :see_other
  end
end
```

```erb
<%# Layout %>
<html>
<head>
  <%= turbo_refreshes_with method: :morph, scroll: :preserve %>
</head>
```

## Real-time Patterns

### Presence Tracking

```ruby
# Channel
class PresenceChannel < ApplicationCable::Channel
  def subscribed
    stream_for document
    document.add_viewer(current_user)
  end

  def unsubscribed
    document.remove_viewer(current_user)
  end
end
```

### Optimistic UI

```javascript
// optimistic_controller.js
export default class extends Controller {
  static targets = ["form", "list"]

  submit(event) {
    event.preventDefault()

    // Optimistically add item
    const tempId = `temp-${Date.now()}`
    const html = this.buildOptimisticItem(tempId)
    this.listTarget.insertAdjacentHTML("beforeend", html)

    // Submit form
    fetch(this.formTarget.action, {
      method: "POST",
      body: new FormData(this.formTarget),
      headers: { "Accept": "text/vnd.turbo-stream.html" }
    })
    .then(response => {
      if (!response.ok) {
        document.getElementById(tempId)?.remove()
      }
      return response.text()
    })
    .then(html => Turbo.renderStreamMessage(html))
  }
}
```
