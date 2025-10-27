# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

create_params = {
  name: "Weekly Newsletter",
  default_subscription: "opt_in",
  description: "Our weekly newsletter with the latest updates"
}

topic = Resend::Topics.create(create_params)
puts "created topic: #{topic[:id]}"

retrieved_topic = Resend::Topics.get(topic[:id])
puts "retrieved topic: #{retrieved_topic[:id]}"
puts "name: #{retrieved_topic[:name]}"
puts "description: #{retrieved_topic[:description]}"
puts "default_subscription: #{retrieved_topic[:default_subscription]}"
puts "created_at: #{retrieved_topic[:created_at]}"

update_params = {
  topic_id: topic[:id],
  name: "Weekly Newsletter - Updated",
  description: "Updated description for our weekly newsletter"
}

updated_topic = Resend::Topics.update(update_params)
puts "updated topic: #{updated_topic[:id]}"

topics = Resend::Topics.list
puts topics

# Example with pagination - use the first topic ID from the list as the 'after' parameter
if topics[:data] && topics[:data].length > 0
  first_topic_id = topics[:data].first[:id]
  paginated_topics = Resend::Topics.list({ limit: 15, after: first_topic_id })
  puts "\nPaginated topics (limit 15, after #{first_topic_id}):"
  puts paginated_topics
end

Resend::Topics.remove(topic[:id])
puts "\nremoved #{topic[:id]}"
