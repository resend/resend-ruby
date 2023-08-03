# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.configure do |config|
  config.api_key = ENV["RESEND_API_KEY"]
end

params = {
  "from": "r@recomendo.io",
  "to": ["emillybalcantara@gmail.com"],
  "text": "test",
  "subject": "test",
  "cc": ["carlosderich1@gmail.com"],
  "bcc": ["carlosderich@gmail.com"],
}

email = Resend::Emails.send(params)
puts(email)

email = Resend::Emails.get email[:id]
puts email[:id]
