# frozen_string_literal: true

require "resend/version"
require "resend/client"

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
