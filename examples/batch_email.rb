# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

params = [
  {
    "from": "r@recomendo.io",
    "to": ["carlosderich@gmail.com"],
    "subject": "hey",
    "html": "<strong>hello, world!</strong>",
  },
  {
    "from": "r@recomendo.io",
    "to": ["carlosderich@gmail.com"],
    "subject": "hello",
    "html": "<strong>hello, world!</strong>",
  },
]

emails = Resend::Batch.send(params)
puts(emails)
