# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

# 1. Create a global contact (needed for event sends)
contact = Resend::Contacts.create({
  email: "test.events@example.com",
  first_name: "Test",
  last_name: "User"
})
contact_id = contact[:id]
puts "created contact: #{contact_id}"

# 2. Create event without schema
event_no_schema = Resend::Events.create({ name: "user.signed_up" })
puts "created event without schema: #{event_no_schema[:id]}"

# 3. Create event with schema
schema = {
  "plan" => "string",
  "trial_days" => "number",
  "is_enterprise" => "boolean",
  "upgraded_at" => "date"
}
event_with_schema = Resend::Events.create({ name: "user.upgraded", schema: schema })
event_id = event_with_schema[:id]
puts "created event with schema: #{event_id}"

# 4. Get event by ID
fetched_by_id = Resend::Events.get(event_id)
puts "fetched event by ID: #{fetched_by_id[:id]}, name: #{fetched_by_id[:name]}"

# 5. Get event by name
fetched_by_name = Resend::Events.get("user.upgraded")
puts "fetched event by name: #{fetched_by_name[:id]}, name: #{fetched_by_name[:name]}"

# 6. Update event schema
new_schema = {
  "plan" => "string",
  "trial_days" => "number",
  "is_enterprise" => "boolean",
  "upgraded_at" => "date",
  "referral_code" => "string"
}
updated_event = Resend::Events.update({ identifier: event_id, schema: new_schema })
puts "updated event: #{updated_event[:id]}"

# 7. Send event with contact_id
sent_with_contact_id = Resend::Events.send({
  event: "user.upgraded",
  contact_id: contact_id,
  payload: { plan: "pro", trial_days: 14, is_enterprise: false }
})
puts "sent event with contact_id: #{sent_with_contact_id[:event]}"

# 8. Send event with email
sent_with_email = Resend::Events.send({
  event: "user.signed_up",
  email: "test.events@example.com"
})
puts "sent event with email: #{sent_with_email[:event]}"

# 9. List events
events = Resend::Events.list
puts "total events: #{events[:data].length}, has_more: #{events[:has_more]}"

# 10. List events with pagination params
paginated = Resend::Events.list({ limit: 5 })
puts "paginated events (limit 5): #{paginated[:data].length}"

if paginated[:has_more]
  last_id = paginated[:data].last[:id]
  more_events = Resend::Events.list({ limit: 5, after: last_id })
  puts "next page: #{more_events[:data].length}"
end

# 11. Delete event by ID
deleted_by_id = Resend::Events.remove(event_id)
puts "deleted event by ID: #{deleted_by_id[:id]}, deleted: #{deleted_by_id[:deleted]}"

# 12. Delete event by name
deleted_by_name = Resend::Events.remove("user.signed_up")
puts "deleted event by name: #{deleted_by_name[:deleted]}"

# 13. Cleanup: delete contact
Resend::Contacts.remove({ id: contact_id })
puts "removed contact: #{contact_id}"
