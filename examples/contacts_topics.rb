# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

def example
  # Note: You'll need to create a topic first via the Topics API
  # For this example, we'll assume you have a topic_id available
  topic_id = ENV["TOPIC_ID"] || "your_topic_id_here"

  # Step 1: Create a contact
  puts "Creating a contact..."
  contact_email = "test-#{Time.now.to_i}@example.com"
  contact = Resend::Contacts.create(
    email: contact_email,
    first_name: "Test",
    last_name: "User"
  )
  contact_id = contact[:id]
  puts "Created contact: #{contact_id} (#{contact_email})"

  # Step 2: List all topics for the contact (should be empty initially)
  puts "\nListing topics for contact (should be empty)..."
  topics = Resend::Contacts::Topics.list(contact_id: contact_id)
  puts "Contact topics: #{topics}"

  # Step 3: Update contact topics (subscribe to topics)
  puts "\nSubscribing contact to topics..."
  result = Resend::Contacts::Topics.update(
    contact_id: contact_id,
    topics: [topic_id]
  )
  puts "Updated contact topics: #{result}"

  # Step 4: List topics again (should now include our topic)
  puts "\nListing topics for contact (should now include the topic)..."
  topics = Resend::Contacts::Topics.list(contact_id: contact_id)
  puts "Contact topics: #{topics}"

  # Step 5: You can also use email instead of contact_id
  puts "\nYou can also use email to list topics..."
  topics_by_email = Resend::Contacts::Topics.list(email: contact_email)
  puts "Topics by email: #{topics_by_email}"

  # Step 6: You can also use pagination parameters
  puts "\nYou can also use pagination parameters..."
  topics_paginated = Resend::Contacts::Topics.list(
    contact_id: contact_id,
    limit: 10
  )
  puts "Topics with pagination: #{topics_paginated}"

  # Step 7: Unsubscribe from all topics
  puts "\nUnsubscribing from all topics..."
  result = Resend::Contacts::Topics.update(
    contact_id: contact_id,
    topics: []
  )
  puts "Updated contact topics: #{result}"

  # Step 8: Cleanup - remove contact
  puts "\nCleaning up..."
  Resend::Contacts.remove(contact_id)
  puts "Deleted contact: #{contact_id}"

  puts "\n✓ Example completed successfully!"
end

example
