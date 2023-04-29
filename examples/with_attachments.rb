# frozen_string_literal: true

require_relative "../lib/resend"
require "stringio"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

file = IO.read(File.join(File.dirname(__FILE__), "../resources/invoice.pdf"))

params = {
  "from": "derich@recomendo.io",
  "to": ["carlosderich@gmail.com"],
  "text": "heyo",
  "subject": "Hello with attachment",
  "attachments": [
    {
      "filename": "invoice.pdf",
      "content": file.bytes # make sure to use .bytes() here
    }
  ]
}

sent = Resend::Emails.send(params)
puts sent
