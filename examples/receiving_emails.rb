# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

puts "=== Listing Received Emails ==="

puts "\nListing all received emails:"
emails = Resend::Emails::Receiving.list

puts "Total emails in response: #{emails[:data].length}"
puts "Has more: #{emails[:has_more]}"

emails[:data].each do |e|
  puts "  - #{e["id"]}: #{e["subject"]} from #{e["from"]}"
  puts "    Created: #{e["created_at"]}"
  if e["attachments"] && !e["attachments"].empty?
    puts "    Attachments: #{e["attachments"].length}"
  end
end

# List with custom limit
puts "\n\nListing with limit of 5:"
limited_emails = Resend::Emails::Receiving.list(limit: 5)

puts "Retrieved #{limited_emails[:data].length} emails"
puts "Has more: #{limited_emails[:has_more]}"

# Example of pagination (if you have more emails)
if limited_emails[:has_more] && limited_emails[:data].last
  last_id = limited_emails[:data].last["id"]
  puts "\n\nGetting next page after ID: #{last_id}"
  next_page = Resend::Emails::Receiving.list(limit: 5, after: last_id)
  puts "Next page has #{next_page[:data].length} emails"
end

puts "\n\n=== Retrieving Single Received Email ==="

# Use the first email from the list, or specify a known ID
if emails[:data] && emails[:data].first
  email_id = emails[:data].first["id"]
else
  # Replace with an actual received email ID from your account
  email_id = "006e2796-ff6a-4436-91ad-0429e600bf8a"
end

email = Resend::Emails::Receiving.get(email_id)

puts "\nEmail Details:"
puts "  ID: #{email[:id]}"
puts "  From: #{email[:from]}"
puts "  To: #{email[:to].join(', ')}"
puts "  Subject: #{email[:subject]}"
puts "  Created At: #{email[:created_at]}"
puts "  Message ID: #{email[:message_id]}"

if email[:cc] && !email[:cc].empty?
  puts "  CC: #{email[:cc].join(', ')}"
end

if email[:bcc] && !email[:bcc].empty?
  puts "  BCC: #{email[:bcc].join(', ')}"
end

if email[:attachments] && !email[:attachments].empty?
  puts "\n  Attachments:"
  email[:attachments].each do |attachment|
    puts "    - #{attachment["filename"]} (#{attachment["content_type"]})"
    puts "      ID: #{attachment["id"]}"
    puts "      Size: #{attachment["size"]} bytes" if attachment["size"]
    puts "      Content ID: #{attachment["content_id"]}" if attachment["content_id"]
  end

  # List all attachments for this email
  puts "\n  Listing all attachments for email: #{email[:id]}"
  attachments_list = Resend::Attachments::Receiving.list(
    email_id: email[:id]
  )

  puts "    Total attachments: #{attachments_list[:data].length}"
  puts "    Has more: #{attachments_list[:has_more]}"

  # Retrieve full attachment details for the first attachment
  if email[:attachments].first
    first_attachment_id = email[:attachments].first["id"]
    puts "\n  Retrieving full attachment details for: #{first_attachment_id}"

    attachment_details = Resend::Attachments::Receiving.get(
      id: first_attachment_id,
      email_id: email[:id]
    )

    puts "    Download URL: #{attachment_details[:download_url]}"
    puts "    Expires At: #{attachment_details[:expires_at]}"
  end
end

puts "\n  HTML Content:"
puts "  #{email[:html][0..100]}..." if email[:html]

puts "\n  Text Content:"
puts "  #{email[:text]}" if email[:text]
