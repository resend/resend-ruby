# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

# Create a new webhook
create_params = {
  endpoint: "https://webhook.example.com/handler",
  events: ["email.sent", "email.delivered", "email.bounced"]
}

webhook = Resend::Webhooks.create(create_params)
puts "Created webhook: #{webhook[:id]}"
puts "Signing secret: #{webhook[:signing_secret]}"

# Retrieve a specific webhook
retrieved_webhook = Resend::Webhooks.get(webhook[:id])
puts "\nRetrieved webhook: #{retrieved_webhook[:id]}"
puts "Endpoint: #{retrieved_webhook[:endpoint]}"
puts "Status: #{retrieved_webhook[:status]}"
puts "Events: #{retrieved_webhook[:events]}"
puts "Created at: #{retrieved_webhook[:created_at]}"

# Update the webhook
update_params = {
  webhook_id: webhook[:id],
  endpoint: "https://new-webhook.example.com/handler",
  events: ["email.sent", "email.delivered"],
  status: "enabled"
}

updated_webhook = Resend::Webhooks.update(update_params)
puts "\nUpdated webhook: #{updated_webhook[:id]}"

# List all webhooks
webhooks = Resend::Webhooks.list
puts "\nTotal webhooks: #{webhooks[:data].length}"
puts "Has more: #{webhooks[:has_more]}"

webhooks[:data].each_with_index do |wh, index|
  puts "\nWebhook #{index + 1}:"
  puts "  ID: #{wh['id']}"
  puts "  Endpoint: #{wh['endpoint']}"
  puts "  Status: #{wh['status']}"
  puts "  Events: #{(wh['events'] || []).join(', ')}"
  puts "  Created at: #{wh['created_at']}"
end

# Example with pagination
if webhooks[:data] && webhooks[:data].length > 0
  first_webhook_id = webhooks[:data].first['id']
  paginated_webhooks = Resend::Webhooks.list({ limit: 10, after: first_webhook_id })
  puts "\nPaginated webhooks (limit 10, after #{first_webhook_id}):"
  puts "Total in page: #{paginated_webhooks[:data].length}"
  puts "Has more: #{paginated_webhooks[:has_more]}"
end

# Remove the webhook
removed_webhook = Resend::Webhooks.remove(webhook[:id])
puts "\nRemoved webhook: #{removed_webhook[:id]}"
puts "Deleted: #{removed_webhook[:deleted]}"
