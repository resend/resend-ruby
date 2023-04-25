# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

def create_api_key_with_defaults
  client = Resend::Client.new(ENV["RESEND_API_KEY"])
  params = {
    # defaults to All Domains when no domain_id is set
    # defaults to `sending_access` when no `permission` is set
    "name": "test1"
  }
  key = client.create_api_key(params)
  puts key
end

def create_api_key_with_permissions
  client = Resend::Client.new(ENV["RESEND_API_KEY"])
  params = {
    "name": "test2",
    "permission": "sending_access"
  }
  key = client.create_api_key(params)
  puts key
end

create_api_key_with_permissions
create_api_key_with_defaults
