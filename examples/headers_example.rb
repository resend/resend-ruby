# frozen_string_literal: true

require "resend"

Resend.api_key = ENV["RESEND_API_KEY"]

# Send an email
params = {
  from: "onboarding@resend.dev",
  to: ["delivered@resend.dev"],
  subject: "Hello World with Headers",
  html: "<p>This example demonstrates accessing response headers</p>"
}

response = Resend::Emails.send(params)

puts "Email ID: #{response[:id]}"
puts "Response keys: #{response.keys.inspect}"

puts "\nResponse Headers:"
puts "  Content-Type: #{response.headers['content-type']}"
puts "  All headers: #{response.headers.keys.inspect}"

# Common use cases for headers:
# - Rate limiting information
if response.headers['x-ratelimit-remaining']
  puts "  Rate Limit Remaining: #{response.headers['x-ratelimit-remaining']}"
end

# - Request tracking
if response.headers['x-request-id']
  puts "  Request ID: #{response.headers['x-request-id']}"
end

# - Response metadata
if response.headers['date']
  puts "  Response Date: #{response.headers['date']}"
end

puts "\n✓ Email sent successfully with ID: #{response[:id]}"
