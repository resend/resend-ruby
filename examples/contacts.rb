# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

def example

  audience_id = "78b8d3bc-a55a-45a3-aee6-6ec0a5e13d7e"

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
    id: contact[:id],
    unsubscribed: true,
  }

  retrieved = Resend::Contacts.get(audience_id, contact[:id])
  puts retrieved

  updated = Resend::Contacts.update(update_params)
  puts "Updated contact: #{updated}"

  contacts = Resend::Contacts.list(audience_id)
  puts contacts

  # delete by id
  del = Resend::Contacts.remove(audience_id, contact[:id])

  # delete by email
  # del = Resend::Contacts.remove(audience_id, "steve@example.com")

  puts "Deleted #{del}"
end

example