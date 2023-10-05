# frozen_string_literal: true

require_relative "../lib/resend"
require "stringio"
require "base64"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

file = IO.read(File.join(File.dirname(__FILE__), "../resources/invoice.pdf"))

params = {
  "from": "onboarding@resend.dev",
  "to": ["delivered@resend.dev"],
  "text": "heyo",
  "subject": "Hello with base 64 encoded attachment",
  "attachments": [
    {
      "filename": "invoice.pdf",
      "content": Base64.encode64(file).to_s
    },
  ]
}

sent = Resend::Emails.send(params)
puts sent
