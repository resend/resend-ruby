# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

def example

  audience_id = "48c269ed-9873-4d60-bdd9-cd7e6fc0b9b8"

  params = {
    audience_id: audience_id,
    email: "steve@woz.com",
    first_name: "Steve",
    last_name: "Woz",
    unsubscribed: false,
  }

  contact = Resend::Contacts.create(params)
  puts "Contact created: #{contact}"

  Resend::Contacts.get(audience_id, contact[:id])
  puts "Retrieved contact: #{contact}"

  contacts = Resend::Contacts.list(audience_id)
  puts contacts

  del = Resend::Contacts.remove(audience_id, contact[:id])
  puts "Deleted #{del}"
end

example