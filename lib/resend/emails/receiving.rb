# frozen_string_literal: true

module Resend
  module Emails
    # Module for receiving emails API operations
    module Receiving
      class << self
        # Retrieve a single received email
        #
        # @param email_id [String] The ID of the received email
        # @return [Hash] The received email object
        #
        # @example
        #   Resend::Emails::Receiving.get("4ef9a417-02e9-4d39-ad75-9611e0fcc33c")
        def get(email_id = "")
          path = "emails/receiving/#{email_id}"
          Resend::Request.new(path, {}, "get").perform
        end

        # List received emails with optional pagination
        #
        # @param params [Hash] Optional parameters for pagination
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
        def list(params = {})
          path = Resend::PaginationHelper.build_paginated_path("emails/receiving", params)
          Resend::Request.new(path, {}, "get").perform
        end
      end
    end
  end
end
