# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

def example

  segment_id = "ca4e37c5-a82a-4199-a3b8-bf912a6472aa"

  params = {
    segment_id: segment_id,
    email: "steve@example.com",
    first_name: "Steve",
    last_name: "Woz",
    unsubscribed: false,
  }

  contact = Resend::Contacts.create(params)
  puts "Contact created: #{contact}"

  update_params = {
    segment_id: segment_id,
    email: params[:email],
    # id: contact[:id],
    unsubscribed: false,
    first_name: "Updated",
  }

  retrieved = Resend::Contacts.get(segment_id, contact[:id])
  puts "Retrived contact by ID"
  puts retrieved

  retrieved_by_email = Resend::Contacts.get(segment_id, contact[:email])
  puts "Retrived contact by Email"
  puts retrieved_by_email

  updated = Resend::Contacts.update(update_params)
  puts "Updated contact: #{updated}"

  contacts = Resend::Contacts.list(segment_id)
  puts contacts

  # Example with pagination
  paginated_contacts = Resend::Contacts.list(segment_id, { limit: 10 })
  puts "Paginated contacts (limit 10):"
  puts paginated_contacts

  # delete by id
  del = Resend::Contacts.remove(segment_id, contact[:id])

  # delete by email
  # del = Resend::Contacts.remove(segment_id, "steve@example.com")

  puts "Deleted #{del}"
end

example