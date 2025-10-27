# frozen_string_literal: true

# Version
require "resend/version"

# Utils
require "httparty"
require "json"
require "cgi"
require "resend/errors"
require "resend/client"
require "resend/request"
require "resend/pagination_helper"

# API Operations
require "resend/audiences"
require "resend/api_keys"
require "resend/broadcasts"
require "resend/batch"
require "resend/contacts"
require "resend/domains"
require "resend/emails"
require "resend/emails/receiving"
require "resend/attachments/receiving"
require "resend/topics"
require "resend/webhooks"

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
