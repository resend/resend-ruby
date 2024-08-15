# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

params = {
  "from": "onboarding@resend.dev",
  "to": ["delivered@resend.dev"],
  "subject": "Hello from Resend (Ruby SDK) - Scheduled",
  "html": "<strong>Hello, from Resend (Ruby SDK)</strong>",

  # ISO 8601 format, you can get that in Ruby with
  # DateTime.now.iso8601(3)
  "scheduled_at": "2024-09-05T11:52:01.858Z",
}

email = Resend::Emails.send(params)
puts(email)

update_params = {
  "email_id": email[:id],
  "scheduled_at": "2024-11-05T11:52:01.858Z",
}

updated_email = Resend::Emails.update(update_params)
puts(updated_email)

canceled = Resend::Emails.cancel(updated_email[:id])
puts(canceled)