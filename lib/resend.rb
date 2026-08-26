# frozen_string_literal: true

# Version
require "resend/version"

# Utils
require "httparty"
require "json"
require "cgi"
require "erb"
require "resend/errors"
require "resend/response"
require "resend/client"
require "resend/request"
require "resend/multipart_request"
require "resend/pagination_helper"

# API Operations
require "resend/segments"
require "resend/api_keys"
require "resend/broadcasts"
require "resend/batch"
require "resend/contacts"
require "resend/contacts/imports"
require "resend/contacts/segments"
require "resend/contacts/topics"
require "resend/contact_properties"
require "resend/domains"
require "resend/domains/claims"
require "resend/emails"
require "resend/templates"
require "resend/emails/receiving"
require "resend/emails/attachments"
require "resend/emails/receiving/attachments"
require "resend/logs"
require "resend/topics"
require "resend/webhooks"
require "resend/oauth_grants"
require "resend/automations"
require "resend/automations/runs"
require "resend/events"
require "resend/suppressions"
require "resend/suppressions/batch"

# Rails
require "resend/railtie" if defined?(Rails) && defined?(ActionMailer)
require "resend/action_mailbox" if defined?(Rails) && defined?(ActionMailbox)

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

  # @deprecated Use Segments instead
  Audiences = Segments
end
