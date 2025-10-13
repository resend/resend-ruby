# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

def create
  params = {
    name: "name"
  }
  key = Resend::ApiKeys.create(params)
  puts key
end

def list
  keys = Resend::ApiKeys.list
  puts keys
end

def list_paginated
  # List with pagination parameters
  paginated_keys = Resend::ApiKeys.list({ limit: 10, after: "key_id_here" })
  puts "Paginated response:"
  puts paginated_keys
  puts "Has more: #{paginated_keys[:has_more]}" if paginated_keys[:has_more]
end

def remove
  key = Resend::ApiKeys.create({name: "t"})
  puts "created api key id: #{key[:id]}"
  Resend::ApiKeys.remove key[:id]
  puts "removed #{key[:id]}"
end

create
# list
# remove
