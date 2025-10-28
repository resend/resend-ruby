# frozen_string_literal: true

module Resend
  module Emails
    module Receiving
      # Module for received email attachments API operations
      module Attachments
        class << self
          # Retrieve a single attachment from a received email
          #
          # @param params [Hash] Parameters for retrieving the attachment
          # @option params [String] :id The attachment ID (required)
          # @option params [String] :email_id The email ID (required)
          # @return [Hash] The attachment object
          #
          # @example
          #   Resend::Emails::Receiving::Attachments.get(
          #     id: "2a0c9ce0-3112-4728-976e-47ddcd16a318",
          #     email_id: "4ef9a417-02e9-4d39-ad75-9611e0fcc33c"
          #   )
          def get(params = {})
            attachment_id = params[:id]
            email_id = params[:email_id]

            path = "emails/receiving/#{email_id}/attachments/#{attachment_id}"
            Resend::Request.new(path, {}, "get").perform
          end

          # List attachments from a received email with optional pagination
          #
          # @param params [Hash] Parameters for listing attachments
          # @option params [String] :email_id The email ID (required)
          # @option params [Integer] :limit Maximum number of attachments to return (1-100)
          # @option params [String] :after Cursor for pagination (newer attachments)
          # @option params [String] :before Cursor for pagination (older attachments)
          # @return [Hash] List of attachments with pagination info
          #
          # @example List all attachments
          #   Resend::Emails::Receiving::Attachments.list(
          #     email_id: "4ef9a417-02e9-4d39-ad75-9611e0fcc33c"
          #   )
          #
          # @example List with custom limit
          #   Resend::Emails::Receiving::Attachments.list(
          #     email_id: "4ef9a417-02e9-4d39-ad75-9611e0fcc33c",
          #     limit: 50
          #   )
          #
          # @example List with pagination
          #   Resend::Emails::Receiving::Attachments.list(
          #     email_id: "4ef9a417-02e9-4d39-ad75-9611e0fcc33c",
          #     limit: 20,
          #     after: "attachment_id_123"
          #   )
          def list(params = {})
            email_id = params[:email_id]
            base_path = "emails/receiving/#{email_id}/attachments"

            # Extract pagination parameters
            pagination_params = params.slice(:limit, :after, :before)

            path = Resend::PaginationHelper.build_paginated_path(base_path, pagination_params)
            Resend::Request.new(path, {}, "get").perform
          end
        end
      end
    end
  end
end
