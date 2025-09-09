# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

params = {
  "from": "onboarding@resend.dev",
  "to": ["delivered@resend.dev"],
  "subject": "Hello from Resend Ruby SDK",
  "text": "test",
  "tags": {
    "country": "br"
  }
}

# With Idempotency
puts "Sending email with Idempotency key:"
email = Resend::Emails.send(params, options: { idempotency_key: "123" })
puts(email)

# Without Idempotency
puts "Sending email without Idempotency key:"
email = Resend::Emails.send(params)
puts(email)

email = Resend::Emails.get(email[:id])
puts(email[:id])

# List emails
puts "\n=== Listing Emails ==="

# List all emails with default limit (20)
puts "Listing all emails:"
emails = Resend::Emails.list
puts "Total emails: #{emails[:data].length}"
puts "Has more: #{emails[:has_more]}"

emails[:data].each do |e|
  puts "  - #{e[:id]}: #{e[:subject]} (#{e[:last_event]})"
end

# List with custom limit
puts "\nListing with limit of 5:"
limited_emails = Resend::Emails.list(limit: 5)
puts "Retrieved #{limited_emails[:data].length} emails"

# Example of pagination (if you have more than 5 emails)
if limited_emails[:has_more] && limited_emails[:data].last
  last_id = limited_emails[:data].last[:id]
  puts "\nGetting next page after ID: #{last_id}"
  next_page = Resend::Emails.list(limit: 5, after: last_id)
  puts "Next page has #{next_page[:data].length} emails"
end