# frozen_string_literal: true

module Resend
  module Domains
    # Domain Forge API wrapper
    module Forge
      class << self
        #
        # Activate Forge on a domain. Returns the full domain, in the same shape
        # as Resend::Domains.get. Enabling a domain that is already migrated is
        # idempotent and returns its current state.
        #
        # @param params [Hash] the parameters
        # @option params [String] :id the ID of the domain (required)
        # @option params [String] :return_path subdomain for the Return-Path address.
        #   When omitted, the server picks a free DNS label.
        #
        # https://resend.com/docs/api-reference/domains/enable-forge
        def enable(params)
          path = "domains/#{params[:id]}/forge"
          Resend::Request.new(path, params.slice(:return_path), "post").perform
        end
      end
    end
  end
end
