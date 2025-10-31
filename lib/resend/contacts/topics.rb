# frozen_string_literal: true

module Resend
  module Contacts
    # Contact Topics api wrapper
    module Topics
      class << self
        #
        # List all topics for a contact
        #
        # @param params [Hash] the parameters
        # @option params [String] :contact_id the contact id (either contact_id or email is required)
        # @option params [String] :email the contact email (either contact_id or email is required)
        # @option params [Integer] :limit the maximum number of results to return (optional)
        # @option params [String] :after the cursor for pagination (optional)
        # @option params [String] :before the cursor for pagination (optional)
        #
        # https://resend.com/docs/api-reference/contacts/list-contact-topics
        def list(params)
          raise ArgumentError, "contact_id or email is required" if params[:contact_id].nil? && params[:email].nil?

          identifier = params[:contact_id] || params[:email]
          base_path = "contacts/#{identifier}/topics"
          path = Resend::PaginationHelper.build_paginated_path(base_path, params)
          Resend::Request.new(path, {}, "get").perform
        end

        #
        # Update topics for a contact
        #
        # @param params [Hash] the parameters
        # @option params [String] :contact_id the contact id (either contact_id or email is required)
        # @option params [String] :email the contact email (either contact_id or email is required)
        # @option params [Array<Hash>] :topics array of topic subscription objects
        #   Each object must have:
        #   - id [String] the topic id
        #   - subscription [String] either "opt_in" or "opt_out"
        #
        # @example
        #   Resend::Contacts::Topics.update(
        #     contact_id: "contact_123",
        #     topics: [
        #       { id: "topic_abc", subscription: "opt_in" },
        #       { id: "topic_xyz", subscription: "opt_out" }
        #     ]
        #   )
        #
        # https://resend.com/docs/api-reference/contacts/update-contact-topics
        def update(params)
          raise ArgumentError, "contact_id or email is required" if params[:contact_id].nil? && params[:email].nil?
          raise ArgumentError, "topics is required" if params[:topics].nil?

          identifier = params[:contact_id] || params[:email]
          path = "contacts/#{identifier}/topics"
          # The API expects a direct array of topic objects, not a hash with a topics key
          Resend::Request.new(path, params[:topics], "patch").perform
        end
      end
    end
  end
end
