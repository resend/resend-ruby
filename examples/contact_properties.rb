# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

def example
  # Create a contact property with string type
  puts "Creating a string contact property..."
  string_property = Resend::ContactProperties.create({
    key: "company_name",
    type: "string",
    fallback_value: "Acme Corp"
  })
  puts "Created property: #{string_property}"

  property_id = string_property[:id]

  # Create a contact property with number type
  puts "\nCreating a number contact property..."
  number_property = Resend::ContactProperties.create({
    key: "age",
    type: "number",
    fallback_value: 0
  })
  puts "Created property: #{number_property}"

  # Retrieve a contact property
  puts "\nRetrieving contact property by ID..."
  retrieved_property = Resend::ContactProperties.get(property_id)
  puts "Retrieved property: #{retrieved_property}"

  # List all contact properties
  puts "\nListing all contact properties..."
  all_properties = Resend::ContactProperties.list
  puts "All properties: #{all_properties}"

  # List contact properties with pagination
  puts "\nListing contact properties with pagination..."
  paginated_properties = Resend::ContactProperties.list({ limit: 10 })
  puts "Paginated properties: #{paginated_properties}"

  # Update a contact property
  puts "\nUpdating contact property..."
  updated_property = Resend::ContactProperties.update({
    id: property_id,
    fallback_value: "Example Company"
  })
  puts "Updated property: #{updated_property}"

  # Delete a contact property
  puts "\nDeleting contact property..."
  deleted = Resend::ContactProperties.remove(property_id)
  puts "Deleted property: #{deleted}"
end

example
