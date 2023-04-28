# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

def create_api_key
  client = Resend::Client.new(ENV["RESEND_API_KEY"])
  params = {
    name: "name"
  }
  key = client.create_api_key(params)
  puts key
end

def list_api_keys
  client = Resend::Client.new(ENV["RESEND_API_KEY"])
  keys = client.list_api_keys
  puts keys
end

def delete_api_key
  client = Resend::Client.new(ENV["RESEND_API_KEY"])
  key = client.create_api_key({name: "t"})
  puts "created api key id: #{key[:id]}"
  client.delete_api_key key[:id]
  client.delete_api_key
  puts "deleted #{key[:id]}"
end

create_api_key
list_api_keys
delete_api_key
