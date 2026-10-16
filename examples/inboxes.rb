# frozen_string_literal: true

require_relative "../lib/resend"
require "base64"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

inbox = Resend::Inboxes.create({ email_address: "support@acme.com", name: "Customer Support" })
inbox_id = inbox[:id]
puts "created inbox: #{inbox_id}"

puts "inbox: #{Resend::Inboxes.get("support@acme.com")[:email_address]}"
puts "inboxes: #{Resend::Inboxes.list(limit: 10)[:data].length}"

Resend::Inboxes.update({ inbox_id: inbox_id, from_name: "Ada from Support" })

Resend::Inboxes::Agent.update({ inbox_id: inbox_id, tone: "concise_casual", actions: ["draft_reply"] })
puts "agent tone: #{Resend::Inboxes::Agent.get({ inbox_id: inbox_id })[:tone]}"

label = Resend::Inboxes::Labels.create({ inbox_id: inbox_id, name: "Urgent", color: "#E93D82" })
Resend::Inboxes::Labels.update({ inbox_id: inbox_id, label_id: label[:id], color: "#F76B15" })
puts "labels: #{Resend::Inboxes::Labels.list({ inbox_id: inbox_id })[:data].length}"

threads = Resend::Inboxes::Threads.list({ inbox_id: inbox_id, folders: %w[inbox sent], read: false })
puts "unread threads: #{threads[:data].length}"

found = Resend::Inboxes::Threads.search({ inbox_id: inbox_id, query: "refund", has_attachment: false })
puts "search results: #{found[:data].length}"

if (thread_id = threads[:data].first&.dig("id"))
  Resend::Inboxes::Threads.update({ inbox_id: inbox_id, thread_id: thread_id, read: true })
  thread_labels = Resend::Inboxes::Threads::Labels.add({ inbox_id: inbox_id, thread_id: thread_id, labels: [label[:id]] })
  puts "thread labels: #{thread_labels[:data].length}"

  emails = Resend::Inboxes::Threads::Emails.list({ inbox_id: inbox_id, thread_id: thread_id })
  email_id = emails[:data].last["id"]
  ids = { inbox_id: inbox_id, thread_id: thread_id, email_id: email_id }

  puts "subject: #{Resend::Inboxes::Threads::Emails.get(ids)[:subject]}"

  reply = Resend::Inboxes::Threads::Emails.reply({ **ids, text: "Thanks, we are on it." })
  puts "reply sent: #{reply[:id]}"

  forward = Resend::Inboxes::Threads::Emails.forward({ **ids, to: ["delivered@resend.dev"], text: "Please check this one." })
  puts "forward sent: #{forward[:id]}"

  Resend::Inboxes::Threads.update({ inbox_id: inbox_id, thread_id: thread_id, remove_label_ids: [label[:id]] })
  Resend::Inboxes::Threads.update({ inbox_id: inbox_id, thread_id: thread_id, folder: "archive" })
  Resend::Inboxes::Threads.remove({ inbox_id: inbox_id, thread_id: thread_id })
end

draft = Resend::Inboxes::Drafts.create({
  inbox_id: inbox_id,
  to: ["delivered@resend.dev"],
  subject: "Hello",
  attachments: [{ filename: "notes.txt", content: Base64.strict_encode64("Hello"), content_type: "text/plain" }]
})
Resend::Inboxes::Drafts.update({ inbox_id: inbox_id, draft_id: draft[:id], text: "Hello from the inbox." })
stored = Resend::Inboxes::Drafts.get({ inbox_id: inbox_id, draft_id: draft[:id] })
puts "draft subject: #{stored[:subject]}, attachments: #{stored[:attachments].length}"
puts "drafts: #{Resend::Inboxes::Drafts.list({ inbox_id: inbox_id })[:data].length}"

sent = Resend::Inboxes::Drafts.send({ inbox_id: inbox_id, draft_id: draft[:id] })
puts "draft sent: #{sent[:id]}"

discarded = Resend::Inboxes::Drafts.create({ inbox_id: inbox_id, subject: "Never sent" })
Resend::Inboxes::Drafts.remove({ inbox_id: inbox_id, draft_id: discarded[:id] })

Resend::Inboxes::Labels.remove({ inbox_id: inbox_id, label_id: label[:id] })
Resend::Inboxes.remove(inbox_id)
puts "removed inbox: #{inbox_id}"
