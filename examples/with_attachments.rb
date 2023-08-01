# frozen_string_literal: true

require_relative "../lib/resend"
require "stringio"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

file = IO.read(File.join(File.dirname(__FILE__), "../resources/invoice.pdf"))

params = {
  "from": "from@email.io",
  "to": ["to@hi.com"],
  "text": "heyo",
  "subject": "Hello with attachment",
  "attachments": [
    {
      "filename": "invoice.pdf", # local file
      "content": file.bytes # make sure to use .bytes() here
    },
    {
      "path": "https://github.com/resendlabs/resend-go/raw/main/resources/invoice.pdf",
      "filename": "from_external_path.pdf"
    }
  ]
}

sent = Resend::Emails.send(params)
puts sent
