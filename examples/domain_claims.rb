# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

def claim_domain
  params = {
    name: "example.com",
    region: "us-east-1"
  }
  claim = Resend::Domains::Claims.create(params)
  puts "Created domain claim: #{claim[:id]}"
  puts "Status: #{claim[:status]}"

  record = claim[:record]
  puts "Add this TXT record to prove ownership: #{record[:name]} = #{record[:value]}" if record

  # Get: poll the claim until the TXT record has been added and verification can run.
  retrieved = Resend::Domains::Claims.get(claim[:domain_id])
  puts "Retrieved domain claim status: #{retrieved[:status]}"

  # Verify: trigger asynchronous DNS verification and ownership transfer.
  verified = Resend::Domains::Claims.verify(claim[:domain_id])
  puts "Verification triggered, claim status: #{verified[:status]}"
end

claim_domain
