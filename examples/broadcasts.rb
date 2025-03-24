# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

# replace with an existing audience id
audience_id = "78b8d3bc-a55a-45a3-aee6-6ec0a5e13d7e"

create_params = {
  from: "onboarding@resend.dev",
  subject: "Hello from Ruby SDK",
  audience_id: audience_id,
  text: "Hello, how are you?",
  name: "Hello from Ruby SDK",
}

broadcast = Resend::Broadcasts.create(create_params)
puts "created broadcast: #{broadcast[:id]}"

update_params = {
  broadcast_id: broadcast[:id],
  name: "Hello from Ruby SDK - updated",
}

updated_broadcast = Resend::Broadcasts.update(update_params)
puts "updated broadcast: #{updated_broadcast[:id]}"

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

if retrieved[:status] == 'draft'
  Resend::Broadcasts.remove(broadcast[:id])
  puts "removed #{broadcast[:id]}"
else
  puts 'Cannot remove a broadcast that is not in draft status'
end