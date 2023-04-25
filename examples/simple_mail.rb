# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

client = Resend::Client.new(ENV["RESEND_API_KEY"])

params = {
  "from": "you@yourdomain.io",
  "to": ["you@examepl.com"],
  "text": "test",
  "subject": "test"
}

sent = client.send_email(params)
puts sent
