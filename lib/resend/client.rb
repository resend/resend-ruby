# frozen_string_literal: true

require "resend/audiences"
require "resend/api_keys"
require "resend/broadcasts"
require "resend/batch"
require "resend/contacts"
require "resend/domains"
require "resend/emails"
require "httparty"

module Resend
  # Client class.
  class Client
    include Resend::Emails

    attr_reader :api_key

    def initialize(api_key)
      raise ArgumentError, "API Key is not a string" unless api_key.is_a?(String)

      @api_key = api_key
    end
  end
end
