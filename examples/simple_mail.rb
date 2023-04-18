# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

client = Resend::Client.new(ENV["RESEND_API_KEY"])

params = {
  "from": "team@recomendo.io",
  "to": ["carlosderich@gmail.com"],
  "text": "test",
  "subject": "test"
}

sent = client.send_email(params)
puts sent
