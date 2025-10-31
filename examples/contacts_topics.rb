# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

def example
  puts "Fetching available topics..."
  all_topics = Resend::Topics.list

  data = all_topics[:data]

  if data.empty?
    puts "No topics found. Please create a topic first using Resend::Topics.create"
    return
  end

  # Use the first available topic for this example
  first_topic = data.first
  topic_id = first_topic["id"]
  topic_name = first_topic["name"]

  puts "Using topic: #{topic_name} (#{topic_id})"

  # Step 2: Create a contact
  puts "\nCreating a contact..."
  contact_email = "test-#{Time.now.to_i}@example.com"
  contact = Resend::Contacts.create(
    email: contact_email,
    first_name: "Test",
    last_name: "User"
  )
  contact_id = contact[:id]
  puts "Created contact: #{contact_id} (#{contact_email})"

  puts "\nListing topics for contact..."
  topics = Resend::Contacts::Topics.list(id: contact_id)
  puts "Contact topics: #{topics}"

  puts "\nSubscribing contact to topic '#{topic_name}'..."
  result = Resend::Contacts::Topics.update(
    id: contact_id,
    topics: [
      { id: topic_id, subscription: "opt_in" }
    ]
  )
  puts "Updated contact topics: #{result}"

  puts "\nListing topics for contact (should show updated subscription)..."
  topics = Resend::Contacts::Topics.list(id: contact_id)
  puts "Contact topics: #{topics}"

  puts "\nYou can also use email to list topics..."
  topics_by_email = Resend::Contacts::Topics.list(email: contact_email)
  puts "Topics by email: #{topics_by_email}"

  puts "\nYou can also use pagination parameters..."
  topics_paginated = Resend::Contacts::Topics.list(id: contact_id, limit: 10)
  puts "Topics with pagination: #{topics_paginated}"

  puts "\nUnsubscribing from topic '#{topic_name}'..."
  result = Resend::Contacts::Topics.update(
    id: contact_id,
    topics: [
      { id: topic_id, subscription: "opt_out" }
    ]
  )
  puts "Updated contact topics: #{result}"

  puts "\nCleaning up..."
  Resend::Contacts.remove(id: contact_id)
  puts "Deleted contact: #{contact_id}"

  puts "\n✓ Example completed successfully!"
end

example
