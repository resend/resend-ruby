# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

def suppressions
  suppression = Resend::Suppressions.add(email: "steve.wozniak@gmail.com")
  puts "Added suppression: #{suppression[:id]}"

  # List: filter by origin and paginate.
  list = Resend::Suppressions.list(origin: "manual", limit: 10)
  list[:data].each do |entry|
    puts "#{entry[:email]} suppressed by #{entry[:origin]} (source: #{entry[:source_id] || "none"})"
  end

  # Get: the path segment accepts either the suppression ID or the email address.
  retrieved = Resend::Suppressions.get("steve.wozniak@gmail.com")
  puts "Retrieved suppression #{retrieved[:id]} created at #{retrieved[:created_at]}"

  removed = Resend::Suppressions.remove(suppression[:id])
  puts "Removed suppression: #{removed[:deleted]}"
end

def batch_suppressions
  added = Resend::Suppressions::Batch.add(
    emails: ["steve.wozniak@gmail.com", "steve.jobs@gmail.com"]
  )
  puts "Added #{added[:data].length} suppressions"

  # Remove: pass either `emails` or `ids`, never both.
  removed = Resend::Suppressions::Batch.remove(ids: added[:data].map { |entry| entry[:id] })
  puts "Removed #{removed[:data].length} suppressions"
end

suppressions
batch_suppressions
