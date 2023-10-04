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

emails = Resend::Batch.send(params)
puts(emails)
