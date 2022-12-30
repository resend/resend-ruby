# frozen_string_literal: true

require "resend/version"
require "resend/client"

require 'resend/railtie' if defined?(Rails) && defined?(ActionMailer)

module Resend
  class << self
    attr_accessor :api_key,
    def configure
      yield self if block_given?
      true
    end
    alias_method :config, :configure
  end
end