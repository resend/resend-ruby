# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

def example
  puts "Creating a contact property..."
  property = Resend::ContactProperties.create(
    key: "user_tier",
    type: "string",
    fallback_value: "free"
  )
  property_id = property[:id]
  puts "Created contact property: #{property_id}"
  puts "Property details: #{property}"

  puts "\nListing all contact properties..."
  properties = Resend::ContactProperties.list
  puts "Contact properties: #{properties}"

  puts "\nListing contact properties with pagination..."
  properties_paginated = Resend::ContactProperties.list(limit: 10)
  puts "Paginated properties: #{properties_paginated}"

  puts "\nGetting contact property by id..."
  property_details = Resend::ContactProperties.get(property_id)
  puts "Property details: #{property_details}"

  puts "\nUpdating contact property..."
  updated_property = Resend::ContactProperties.update(
    id: property_id,
    fallback_value: "premium"
  )
  puts "Updated property: #{updated_property}"

  puts "\nCleaning up..."
  deleted = Resend::ContactProperties.remove(property_id)
  puts "Deleted contact property: #{deleted}"

  puts "\n✓ Example completed successfully!"
end

example
