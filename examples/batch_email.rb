# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

params = [
  {
    "from": "onboarding@resend.dev",
    "to": ["delivered@resend.dev"],
    "subject": "hey",
    "html": "<strong>hello, world!</strong>",
  },
  {
    "from": "onboarding@resend.dev",
    "to": ["delivered@resend.dev"],
    "subject": "hello",
    "html": "<strong>hello, world!</strong>",
  },
]

# Send a batch of emails without Idempotency key
emails = Resend::Batch.send(params)
puts "Emails sent without Idempotency key:"
puts(emails)

# Send a batch of emails with Idempotency key
emails = Resend::Batch.send(params, options: { idempotency_key: "af67ff1cdf3cdf1" })
puts "Emails sent with Idempotency key:"
puts(emails)