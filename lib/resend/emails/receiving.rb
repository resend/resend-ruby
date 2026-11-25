# frozen_string_literal: true

module Resend
  module Emails
    # Module for receiving emails API operations
    module Receiving
      class << self
        # Retrieve a single received email
        #
        # @param email_id [String] The ID of the received email
        # @param params [Hash] Optional query parameters
        # @option params [String] :html_format Format of the HTML content (e.g., "sanitized", "raw")
        # @return [Hash] The received email object
        #
        # @example
        #   Resend::Emails::Receiving.get("4ef9a417-02e9-4d39-ad75-9611e0fcc33c")
        #
        # @example With html_format
        #   Resend::Emails::Receiving.get("4ef9a417-02e9-4d39-ad75-9611e0fcc33c", html_format: "sanitized")
        def get(email_id = "", params = {})
          path = "emails/receiving/#{email_id}"

          path += "?html_format=#{CGI.escape(params[:html_format].to_s)}" if params[:html_format]

          Resend::Request.new(path, {}, "get").perform
        end

        # List received emails with optional filters and pagination
        #
        # Filters combine, so an email must match all of them.
        #
        # @param params [Hash] Optional filters and pagination parameters
        # @option params [Array<String>] :to recipients. Returns emails received by any of these addresses.
        #   Each value is an exact, case-sensitive match on the envelope recipient. Up to 20 values
        # @option params [String] :start_date matches emails received on or after this date. Accepts a date
        #   like `2026-09-01` or an ISO 8601 timestamp, in UTC unless the timestamp has an offset
        # @option params [String] :end_date matches emails received on or before this date. Same formats as
        #   `start_date`. A date covers that whole day. Must not be before `start_date`
        # @option params [Integer] :limit Maximum number of emails to return (1-100)
        # @option params [String] :after Cursor for pagination (newer emails)
        # @option params [String] :before Cursor for pagination (older emails)
        # @return [Hash] List of received emails with pagination info
        #
        # @example List all received emails
        #   Resend::Emails::Receiving.list
        #
        # @example List with custom limit
        #   Resend::Emails::Receiving.list(limit: 50)
        #
        # @example List with pagination
        #   Resend::Emails::Receiving.list(limit: 20, after: "email_id_123")
        #
        # @example List emails received by an address in a date range
        #   Resend::Emails::Receiving.list(to: ["support@acme.com"], start_date: "2026-11-01", end_date: "2026-11-15")
        def list(params = {})
          # The API reads `to` as one comma-separated value and rejects a repeated parameter.
          query = params.transform_values { |value| value.is_a?(Array) ? value.join(",") : value }
          path = Resend::PaginationHelper.build_paginated_path("emails/receiving", query)
          Resend::Request.new(path, {}, "get").perform
        end
      end
    end
  end
end
