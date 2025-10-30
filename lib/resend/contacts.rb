# frozen_string_literal: true

module Resend
  # Contacts api wrapper
  module Contacts
    class << self
      # https://resend.com/docs/api-reference/contacts/create-contact
      def create(params)
        path = "segments/#{params[:segment_id]}/contacts"
        Resend::Request.new(path, params, "post").perform
      end

      #
      # Retrieves a contact from a segment
      #
      # @param segment_id [String] the segment id
      # @param id [String] either the contact id or contact's email
      #
      # https://resend.com/docs/api-reference/contacts/get-contact
      def get(segment_id, id)
        path = "segments/#{segment_id}/contacts/#{id}"
        Resend::Request.new(path, {}, "get").perform
      end

      #
      # List contacts in a segment
      #
      # @param segment_id [String] the segment id
      # @param params [Hash] optional pagination parameters
      # https://resend.com/docs/api-reference/contacts/list-contacts
      def list(segment_id, params = {})
        path = Resend::PaginationHelper.build_paginated_path("segments/#{segment_id}/contacts", params)
        Resend::Request.new(path, {}, "get").perform
      end

      #
      # Remove a contact from a segment
      #
      # @param segment_id [String] the segment id
      # @param contact_id [String] either the contact id or contact email
      #
      # see also: https://resend.com/docs/api-reference/contacts/delete-contact
      def remove(segment_id, contact_id)
        path = "segments/#{segment_id}/contacts/#{contact_id}"
        Resend::Request.new(path, {}, "delete").perform
      end

      #
      # Update a contact
      #
      # @param params [Hash] the contact params
      # https://resend.com/docs/api-reference/contacts/update-contact
      def update(params)
        raise ArgumentError, "id or email is required" if params[:id].nil? && params[:email].nil?

        path = "segments/#{params[:segment_id]}/contacts/#{params[:id] || params[:email]}"
        Resend::Request.new(path, params, "patch").perform
      end
    end
  end
end
