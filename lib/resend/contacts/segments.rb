# frozen_string_literal: true

module Resend
  module Contacts
    # Contact Segments api wrapper
    module Segments
      class << self
        #
        # List all segments for a contact
        #
        # @param params [Hash] the parameters
        # @option params [String] :contact_id the contact id (either contact_id or email is required)
        # @option params [String] :email the contact email (either contact_id or email is required)
        # @option params [Integer] :limit the maximum number of results to return (optional)
        # @option params [String] :after the cursor for pagination (optional)
        # @option params [String] :before the cursor for pagination (optional)
        #
        # https://resend.com/docs/api-reference/contacts/list-contact-segments
        def list(params)
          raise ArgumentError, "contact_id or email is required" if params[:contact_id].nil? && params[:email].nil?

          identifier = params[:contact_id] || params[:email]
          base_path = "contacts/#{identifier}/segments"
          path = Resend::PaginationHelper.build_paginated_path(base_path, params)
          Resend::Request.new(path, {}, "get").perform
        end

        #
        # Add a contact to a segment
        #
        # @param params [Hash] the parameters
        # @option params [String] :contact_id the contact id (either contact_id or email is required)
        # @option params [String] :email the contact email (either contact_id or email is required)
        # @option params [String] :segment_id the segment id (required)
        #
        # https://resend.com/docs/api-reference/contacts/add-contact-to-segment
        def add(params)
          raise ArgumentError, "contact_id or email is required" if params[:contact_id].nil? && params[:email].nil?
          raise ArgumentError, "segment_id is required" if params[:segment_id].nil?

          identifier = params[:contact_id] || params[:email]
          path = "contacts/#{identifier}/segments/#{params[:segment_id]}"
          Resend::Request.new(path, {}, "post").perform
        end

        #
        # Remove a contact from a segment
        #
        # @param params [Hash] the parameters
        # @option params [String] :contact_id the contact id (either contact_id or email is required)
        # @option params [String] :email the contact email (either contact_id or email is required)
        # @option params [String] :segment_id the segment id (required)
        #
        # https://resend.com/docs/api-reference/contacts/remove-contact-from-segment
        def remove(params)
          raise ArgumentError, "contact_id or email is required" if params[:contact_id].nil? && params[:email].nil?
          raise ArgumentError, "segment_id is required" if params[:segment_id].nil?

          identifier = params[:contact_id] || params[:email]
          path = "contacts/#{identifier}/segments/#{params[:segment_id]}"
          Resend::Request.new(path, {}, "delete").perform
        end
      end
    end
  end
end
