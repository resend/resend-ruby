# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

params = {
  from: "onboarding@resend.dev",
  subject: "Hello",
  audience_id: "78b8d3bc-a55a-45a3-aee6-6ec0a5e13d7e",
  text: "Hello, how are you?",
}

broadcast = Resend::Broadcasts.create(params)
puts "created broadcast: #{broadcast[:id]}"

send_params = {
  broadcast_id: broadcast[:id],
  scheduled_at: "in 1 min",
}

sent_broadcast = Resend::Broadcasts.send(send_params)
puts "sent broadcast: #{sent_broadcast[:id]}"

broadcasts = Resend::Broadcasts.list
puts broadcasts

retrieved = Resend::Broadcasts.get(broadcast[:id])
puts "retrieved #{retrieved[:id]}"

Resend::Broadcasts.remove(broadcast[:id])
puts "removed #{broadcast[:id]}"