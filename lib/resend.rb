# frozen_string_literal: true

# Version
require "resend/version"

# Utils
require "httparty"
require "json"
require "resend/errors"
require "resend/client"
require "resend/request"

# API Operations
require "resend/audiences"
require "resend/api_keys"
require "resend/broadcasts"
require "resend/batch"
require "resend/contacts"
require "resend/domains"
require "resend/emails"

# Rails
require "resend/railtie" if defined?(Rails) && defined?(ActionMailer)

# Main Resend module
module Resend
  class << self
    attr_accessor :api_key

    def configure
      yield self if block_given?
      true
    end
    alias config configure
  end
end
