# frozen_string_literal: true

require_relative "../lib/resend"
require "stringio"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

file = IO.read(File.join(File.dirname(__FILE__), "../resources/invoice.pdf"))

params = {
  "from": "onboarding@resend.dev",
  "to": ["delivered@resend.dev"],
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

inline_attachment_params = {
  "from": "onboarding@resend.dev",
  "to": ["delivered@resend.dev"],
  "html": "<p>This is an email with an <img width=100 height=40 src=\"cid:image\" /> embed image</p>",
  "subject": "Resend Ruby SDK inline attachment example",
  "attachments": [
    {
      "path": "https://resend.com/static/brand/resend-wordmark-black.png",
      "filename": "resend-wordmark-black.png",
      "content_id": "image"
    }
  ]
}

sent = Resend::Emails.send(inline_attachment_params)
puts sent