# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

# replace with an existing segment id
segment_id = "78b8d3bc-a55a-45a3-aee6-6ec0a5e13d7e"

create_params = {
  from: "onboarding@resend.dev",
  subject: "Hello from Ruby SDK",
  segment_id: segment_id,
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

# Example with pagination - only demonstrate if has_more is true
if broadcasts[:has_more]
  # In real usage, you'd use the cursor from the previous response
  # For this example, we just show pagination with limit
  paginated_broadcasts = Resend::Broadcasts.list({ limit: 5 })
  puts "\nPaginated broadcasts (limit 5):"
  puts paginated_broadcasts
else
  puts "\nNo more broadcasts to paginate through"
end

retrieved = Resend::Broadcasts.get(broadcast[:id])
puts "retrieved #{retrieved[:id]}"
puts "html: #{retrieved[:html]}"
puts "text: #{retrieved[:text]}"

if retrieved[:status] == 'draft'
  Resend::Broadcasts.remove(broadcast[:id])
  puts "removed #{broadcast[:id]}"
else
  puts 'Cannot remove a broadcast that is not in draft status'
end