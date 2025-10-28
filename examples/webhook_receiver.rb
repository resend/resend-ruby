# frozen_string_literal: true

require "sinatra"
require "json"
require_relative "../lib/resend"

# Demonstrates how to receive and verify webhooks
# This example creates an HTTP server that listens for webhook POST requests
# and verifies them using the verify method
#
# Usage:
#   1. Install Sinatra if you haven't already: gem install sinatra
#   2. Set your webhook secret: export WEBHOOK_SECRET="whsec_1234567890abcdefghijklmnopqrstuvwxyz"
#   3. Run this script: ruby examples/webhook_receiver.rb
#   4. The server will listen on http://localhost:5000/webhook
#   5. Configure your Resend webhook to point to this endpoint (or use a tool like ngrok for testing)

# Configure Sinatra
set :port, 5000
set :bind, "0.0.0.0"

# Get webhook secret from environment variable
WEBHOOK_SECRET = "whsec_LCirqMN5FjMrOGiAqbUfBAdbEdA0Iezg"

if WEBHOOK_SECRET.nil? || WEBHOOK_SECRET.empty?
  puts "Error: WEBHOOK_SECRET environment variable is required"
  puts "Usage: WEBHOOK_SECRET=whsec_xxx ruby examples/webhook_receiver.rb"
  exit 1
end

# Webhook endpoint
post "/webhook" do
  # Read the raw body (must be raw for signature verification)
  request.body.rewind
  payload = request.body.read

  # Extract Svix headers
  headers = {
    svix_id: request.env["HTTP_SVIX_ID"],
    svix_timestamp: request.env["HTTP_SVIX_TIMESTAMP"],
    svix_signature: request.env["HTTP_SVIX_SIGNATURE"]
  }

  # Verify the webhook
  begin
    Resend::Webhooks.verify(
      payload: payload,
      headers: headers,
      webhook_secret: WEBHOOK_SECRET
    )

    # Parse the verified payload
    webhook_data = JSON.parse(payload)

    puts "✓ Webhook verified successfully!"
    puts "Event Type: #{webhook_data['type']}"
    puts "Payload: #{JSON.pretty_generate(webhook_data)}"

    # Return success response
    content_type :json
    status 200
    { success: true }.to_json
  rescue StandardError => e
    puts "✗ Webhook verification failed: #{e.message}"

    # Return error response
    content_type :json
    status 400
    { success: false, error: e.message }.to_json
  end
end

# Start message
puts "Resend Webhook Receiver"
puts "Listening on http://localhost:5000/webhook"
puts "Visit http://localhost:5000 for documentation"
puts ""
puts "Press Ctrl+C to stop the server"
