# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

def example
  params = {
    name: "New Segment One",
  }
  segment = Resend::Segments.create(params)
  puts "Created new segment: #{segment[:id]}"

  Resend::Segments.get(segment[:id])
  puts "retrieved segment id: #{segment[:id]}"

  segments = Resend::Segments.list
  puts segments

  # Example with pagination
  paginated_segments = Resend::Segments.list({ limit: 5 })
  puts "Paginated segments (limit 5):"
  puts paginated_segments

  Resend::Segments.remove segment[:id]
  puts "deleted #{segment[:id]}"
end

example