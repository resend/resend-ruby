# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

params = {
  "from": "from@email.io",
  "to": ["to@gmail.com"],
  "text": "test",
  "subject": "test",
  "tags": {
    "country": "br"
  }
}

email = Resend::Emails.send(params)
puts(email)

email = Resend::Emails.get email[:id]
puts email[:id]
