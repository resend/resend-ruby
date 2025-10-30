# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

def example

  audience_id = "ca4e37c5-a82a-4199-a3b8-bf912a6472aa"

  params = {
    audience_id: audience_id,
    email: "steve@example.com",
    first_name: "Steve",
    last_name: "Woz",
    unsubscribed: false,
  }

  contact = Resend::Contacts.create(params)
  puts "Contact created: #{contact}"

  update_params = {
    audience_id: audience_id,
    email: params[:email],
    # id: contact[:id],
    unsubscribed: false,
    first_name: "Updated",
  }

  retrieved = Resend::Contacts.get(audience_id, contact[:id])
  puts "Retrived contact by ID"
  puts retrieved

  retrieved_by_email = Resend::Contacts.get(audience_id, contact[:email])
  puts "Retrived contact by Email"
  puts retrieved_by_email

  updated = Resend::Contacts.update(update_params)
  puts "Updated contact: #{updated}"

  contacts = Resend::Contacts.list(audience_id)
  puts contacts

  # Example with pagination
  paginated_contacts = Resend::Contacts.list(audience_id, { limit: 10 })
  puts "Paginated contacts (limit 10):"
  puts paginated_contacts

  # === Contact Topics ===
  puts "\n=== Contact Topics ==="

  # Create a topic first (required for contact topics operations)
  topic_params = {
    name: "Product Updates #{Time.now.to_i}",
    description: "Updates about our products",
    default_subscription: "opt_out"
  }

  topic = Resend::Topics.create(topic_params)
  puts "Topic created: #{topic}"
  topic_id = topic[:id]

  # Get contact topics
  puts "\nGetting contact topics..."
  contact_topics = Resend::Contacts::Topics.get(contact[:id])
  puts "Contact topics: #{contact_topics}"

  # Update contact topic subscriptions - opt in to the topic
  puts "\nOpting in to topic..."
  update_topics_params = {
    id: contact[:id],
    topics: [
      { id: topic_id, subscription: "opt_in" }
    ]
  }

  updated_topics = Resend::Contacts::Topics.update(update_topics_params)
  puts "Updated topic subscription: #{updated_topics}"

  # Get contact topics again to see the updated subscription
  puts "\nGetting contact topics after opt-in..."
  contact_topics_after = Resend::Contacts::Topics.get(contact[:id])
  puts "Contact topics after update: #{contact_topics_after}"

  # Update contact topic subscriptions - opt out from the topic
  puts "\nOpting out from topic..."
  update_topics_params[:topics] = [
    { id: topic_id, subscription: "opt_out" }
  ]

  updated_topics_opt_out = Resend::Contacts::Topics.update(update_topics_params)
  puts "Opted out from topic: #{updated_topics_opt_out}"

  # Clean up: delete the topic
  puts "\nCleaning up topic..."
  Resend::Topics.remove(topic_id)
  puts "Topic deleted"

  # delete by id
  del = Resend::Contacts.remove(audience_id, contact[:id])

  # delete by email
  # del = Resend::Contacts.remove(audience_id, "steve@example.com")

  puts "Deleted #{del}"
end

example