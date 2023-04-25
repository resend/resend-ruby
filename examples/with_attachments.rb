# frozen_string_literal: true

require_relative "../lib/resend"
require "stringio"

raise if ENV["RESEND_API_KEY"].nil?

client = Resend::Client.new(ENV["RESEND_API_KEY"])

file = IO.read(File.join(File.dirname(__FILE__), "../resources/invoice.pdf"))

params = {
  "from": "you@yourdomain.io",
  "to": ["someone@example.com"],
  "text": "heyo",
  "subject": "Hello with attachment",
  "attachments": [
    "filename": "invoice.pdf",
    "content": file.bytes # make sure to use .bytes() here
  ]
}

sent = client.send_email(params)
puts sent
