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

email = Resend::Emails.send(params)
puts(email)

email = Resend::Emails.get email[:id]
puts email[:id]
