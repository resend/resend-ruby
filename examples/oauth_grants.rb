# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

def list
  grants = Resend::OAuthGrants.list
  puts grants
end

def list_paginated
  paginated_grants = Resend::OAuthGrants.list({ limit: 10, after: "grant_id_here" })
  puts "Paginated response:"
  puts paginated_grants
  puts "Has more: #{paginated_grants[:has_more]}" if paginated_grants[:has_more]
end

def remove
  grant = Resend::OAuthGrants.remove("oauth_grant_id_here")
  puts grant
end

list
# list_paginated
# remove
