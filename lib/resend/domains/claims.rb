# frozen_string_literal: true

module Resend
  module Domains
    # Domain Claims API wrapper
    module Claims
      class << self
        #
        # Start a claim for a domain that another Resend account has already verified.
        # The domain is recreated under your account with fresh DKIM keys, so the
        # previous account's DNS records cannot be reused. Returns a TXT record to add
        # to your DNS to prove ownership. Uses the same request body as creating a domain.
        #
        # @param params [Hash] the parameters
        # @option params [String] :name the name of the domain you want to claim (required)
        # @option params [String] :region the region where emails will be sent from.
        #   Possible values: 'us-east-1' | 'eu-west-1' | 'sa-east-1' | 'ap-northeast-1'
        # @option params [String] :custom_return_path subdomain for the Return-Path address (default 'send')
        # @option params [String] :tracking_subdomain the custom subdomain used for click and open tracking links
        # @option params [Boolean] :click_tracking track clicks within the body of each HTML email
        # @option params [Boolean] :open_tracking track the open rate of each email
        #
        # https://resend.com/docs/api-reference/domains/claim-domain
        def create(params)
          path = "domains/claim"
          Resend::Request.new(path, params, "post").perform
        end

        #
        # Retrieve the latest claim for the placeholder domain created by the claim.
        #
        # @param domain_id [String] the ID of the placeholder domain created by the claim
        #
        # https://resend.com/docs/api-reference/domains/get-domain-claim
        def get(domain_id = "")
          path = "domains/#{domain_id}/claim"
          Resend::Request.new(path, {}, "get").perform
        end

        #
        # Trigger asynchronous DNS verification and ownership transfer for a domain claim.
        # The claim stays 'pending' while verification runs; poll `get` for status. Once
        # 'completed', the transferred domain has new DKIM records that must be added to
        # DNS and verified via Resend::Domains.verify.
        #
        # @param domain_id [String] the ID of the placeholder domain created by the claim
        #
        # https://resend.com/docs/api-reference/domains/verify-domain-claim
        def verify(domain_id = "")
          path = "domains/#{domain_id}/claim/verify"
          Resend::Request.new(path, {}, "post").perform
        end
      end
    end
  end
end
