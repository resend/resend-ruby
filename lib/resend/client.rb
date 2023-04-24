# frozen_string_literal: true

require "resend/version"
require "resend/errors"
require "resend/api_keys"
require "resend/emails"
require "httparty"

module Resend
  # Main Resend client class, most methods should live here.
  class Client
    include Resend::ApiKeys
    include Resend::Emails

    attr_reader :api_key, :base_url, :timeout

    def initialize(api_key)
      raise ArgumentError, "API Key is not a string" unless api_key.is_a?(String)

      @api_key = api_key
      @timeout = nil
    end
  end
end
