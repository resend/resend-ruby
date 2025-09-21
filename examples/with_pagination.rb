# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

puts "=== Resend Ruby SDK Pagination Examples ==="
puts

# API Keys pagination
puts "1. API Keys Pagination:"
puts "List first 5 API keys:"
api_keys = Resend::ApiKeys.list({ limit: 5 })
puts api_keys
puts "Has more: #{api_keys[:has_more]}" if api_keys.key?(:has_more)
puts

# Audiences pagination
puts "2. Audiences Pagination:"
puts "List first 10 audiences:"
audiences = Resend::Audiences.list({ limit: 10 })
puts audiences
puts "Has more: #{audiences[:has_more]}" if audiences.key?(:has_more)
puts

# If we have audiences, demonstrate pagination with 'after'
if audiences[:data] && !audiences[:data].empty?
  first_audience_id = audiences[:data].first[:id]
  puts "List audiences after '#{first_audience_id}':"
  next_audiences = Resend::Audiences.list({ limit: 5, after: first_audience_id })
  puts next_audiences
  puts
end

# Domains pagination
puts "3. Domains Pagination:"
puts "List first 3 domains:"
domains = Resend::Domains.list({ limit: 3 })
puts domains
puts "Has more: #{domains[:has_more]}" if domains.key?(:has_more)
puts

# Broadcasts pagination
puts "4. Broadcasts Pagination:"
puts "List first 2 broadcasts:"
broadcasts = Resend::Broadcasts.list({ limit: 2 })
puts broadcasts
puts "Has more: #{broadcasts[:has_more]}" if broadcasts.key?(:has_more)
puts

# Contacts pagination (requires an audience ID)
puts "5. Contacts Pagination:"
if audiences[:data] && !audiences[:data].empty?
  audience_id = audiences[:data].first[:id]
  if audience_id && !audience_id.empty?
    puts "List first 5 contacts from audience '#{audience_id}':"
    begin
      contacts = Resend::Contacts.list(audience_id, { limit: 5 })
      puts contacts
      puts "Has more: #{contacts[:has_more]}" if contacts.key?(:has_more)
    rescue Resend::Error => e
      puts "Error listing contacts: #{e.message}"
      puts "(This might happen if the audience has no contacts or access is restricted)"
    end
  else
    puts "Audience ID is empty, skipping contacts pagination example"
  end
else
  puts "No audiences available for contacts pagination example"
end
puts

puts "=== Pagination Parameters ==="
puts "• limit: Number of items to retrieve (1-100)"
puts "• after: ID after which to retrieve more items"
puts "• before: ID before which to retrieve more items"
puts
puts "Example usage:"
puts "Resend::ApiKeys.list({ limit: 25, after: 'key_123' })"
puts "Resend::Domains.list({ limit: 10, before: 'domain_456' })"
puts "Resend::Contacts.list('audience_id', { limit: 50 })"