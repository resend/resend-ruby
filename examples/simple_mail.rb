# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.configure do |config|
  config.api_key = ENV["RESEND_API_KEY"]
end

params = {
  "from": "derich@recomendo.io",
  "to": ["carlosderich@gmail.com"],
  "text": "test",
  "subject": "test",
  "tags": {
    "country": "br"
  }
}

puts(Resend::Emails.send(params))

# client = Resend::Client.new Resend.api_key
# client.send_email(params)
