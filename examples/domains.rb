# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

def create
  params = {
    name: "name",
    region: ""
  }
  domain = Resend::Domains.create(params)
  puts domain
end

def list
  domains = Resend::Domains.list
  puts domains
end

def remove
  key = Resend::Domains.create({name: "test"})
  puts "created domain id: #{key[:id]}"
  Resend::Domains.remove key[:id]
  puts "deleted #{key[:id]}"
end

def verify
  key = Resend::Domains.create({name: "test2"})
  puts "created domain id: #{key[:id]}"
  Resend::Domains.verify key[:id]
  puts "verified #{key[:id]}"
end

create
list
remove
verify
