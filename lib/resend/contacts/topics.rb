# frozen_string_literal: true

module Resend
  module Contacts
    # Module for managing contact topic subscriptions
    #
    # Allows you to manage which topics contacts are subscribed to
    module Topics
      class << self
        # Retrieve a list of topics subscriptions for a contact
        #
        # @param params [Hash] Parameters for listing topics
        # @option params [String] :id The Contact ID (either :id or :email must be provided)
        # @option params [String] :email The Contact Email (either :id or :email must be provided)
        # @option params [Integer] :limit Number of topics to retrieve (1-100)
        # @option params [String] :after The ID after which to retrieve more topics
        # @option params [String] :before The ID before which to retrieve more topics
        #
        # @return [Hash] Response containing list of topics with subscription status
        #
        # @example List topics by contact ID
        #   Resend::Contacts::Topics.list(id: 'e169aa45-1ecf-4183-9955-b1499d5701d3')
        #
        # @example List topics by contact email
        #   Resend::Contacts::Topics.list(email: 'steve.wozniak@gmail.com')
        #
        # @example List topics with pagination
        #   Resend::Contacts::Topics.list(id: 'contact-id', limit: 10, after: 'cursor_123')
        def list(params = {})
          contact_identifier = params[:id] || params[:email]
          raise ArgumentError, "Either :id or :email must be provided" if contact_identifier.nil?

          pagination_params = params.slice(:limit, :after, :before)
          base_path = "contacts/#{contact_identifier}/topics"
          path = Resend::PaginationHelper.build_paginated_path(base_path, pagination_params)

          Resend::Request.new(path, {}, "get").perform
        end

        # Update topic subscriptions for a contact
        #
        # @param params [Hash] Parameters for updating topics
        # @option params [String] :id The Contact ID (either :id or :email must be provided)
        # @option params [String] :email The Contact Email (either :id or :email must be provided)
        # @option params [Array<Hash>] :topics Array of topic subscription updates
        #   Each topic hash should contain:
        #   - :id [String] The Topic ID (required)
        #   - :subscription [String] The subscription action: 'opt_in' or 'opt_out' (required)
        #
        # @return [Hash] Response containing the contact ID
        #
        # @example Update by contact ID
        #   Resend::Contacts::Topics.update({
        #     id: 'e169aa45-1ecf-4183-9955-b1499d5701d3',
        #     topics: [
        #       { id: 'b6d24b8e-af0b-4c3c-be0c-359bbd97381e', subscription: 'opt_out' },
        #       { id: '07d84122-7224-4881-9c31-1c048e204602', subscription: 'opt_in' }
        #     ]
        #   })
        #
        # @example Update by contact email
        #   Resend::Contacts::Topics.update({
        #     email: 'steve.wozniak@gmail.com',
        #     topics: [
        #       { id: '07d84122-7224-4881-9c31-1c048e204602', subscription: 'opt_out' }
        #     ]
        #   })
        def update(params)
          contact_identifier = params[:id] || params[:email]
          raise ArgumentError, "Either :id or :email must be provided" if contact_identifier.nil?

          path = "contacts/#{contact_identifier}/topics"
          body = params[:topics]

          Resend::Request.new(path, body, "patch").perform
        end
      end
    end
  end
end
