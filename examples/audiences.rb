# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

def example
  params = {
    name: "New Audience One",
  }
  audience = Resend::Audiences.create(params)
  puts "Created new audience: #{audience[:id]}"

  Resend::Audiences.get(audience[:id])
  puts "retrieved audience id: #{audience[:id]}"

  audiences = Resend::Audiences.list
  puts audiences

  # Example with pagination
  paginated_audiences = Resend::Audiences.list({ limit: 5 })
  puts "Paginated audiences (limit 5):"
  puts paginated_audiences

  Resend::Audiences.remove audience[:id]
  puts "deleted #{audience[:id]}"
end

example