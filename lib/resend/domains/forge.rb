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
        #   When omitted, the API picks a suggested label based on the domain's
        #   current return path.
        #
        # https://resend.com/docs/api-reference/domains/enable-forge
        def enable(params)
          path = "domains/#{params[:id]}/forge"
          Resend::Request.new(path, params.slice(:return_path), "post").perform
        end

        #
        # Move the Return-Path of a Forge domain and re-verify it. Returns the
        # full domain. After the domain verifies, the API refuses this with a
        # 422 'return_path_unavailable'.
        #
        # @param params [Hash] the parameters
        # @option params [String] :id the ID of the domain (required)
        # @option params [String] :return_path subdomain for the Return-Path address (required)
        #
        # https://resend.com/docs/api-reference/domains/update-forge
        def update(params)
          raise ArgumentError, "return_path is required" if params[:return_path].nil?

          path = "domains/#{params[:id]}/forge"
          Resend::Request.new(path, params.slice(:return_path), "patch").perform
        end

        #
        # Trigger asynchronous Forge verification for a domain. Answers with the
        # `{ object: 'domain', id }` pair like Resend::Domains.verify; poll
        # Resend::Domains.get for state.
        #
        # @param domain_id [String] the ID of the domain
        #
        # https://resend.com/docs/api-reference/domains/verify-forge
        def verify(domain_id = "")
          path = "domains/#{domain_id}/forge/verify"
          Resend::Request.new(path, {}, "post").perform
        end
      end
    end
  end
end
