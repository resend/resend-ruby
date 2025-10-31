# frozen_string_literal: true

module Resend
  # Contacts api wrapper
  module Contacts
    class << self
      # https://resend.com/docs/api-reference/contacts/create-contact
      def create(params)
        if params[:audience_id]
          path = "audiences/#{params[:audience_id]}/contacts"
          # Audience-scoped contacts don't support properties
          payload = params.reject { |key, _| key == :properties }
        else
          path = "contacts"
          payload = params
        end
        Resend::Request.new(path, payload, "post").perform
      end

      #
      # Retrieves a contact
      #
      # @param params [Hash] the parameters
      # @option params [String] :id either the contact id or contact's email (required)
      # @option params [String] :audience_id optional audience id to scope the operation
      #
      # @example Get contact by ID
      #   Resend::Contacts.get(id: "contact_123")
      #
      # @example Get contact scoped to an audience
      #   Resend::Contacts.get(id: "contact_123", audience_id: "aud_456")
      #
      # https://resend.com/docs/api-reference/contacts/get-contact
      def get(params = {})
        raise ArgumentError, "Missing `id` or `email` field" if params[:id].nil? && params[:email].nil?

        audience_id = params[:audience_id]
        contact_id = params[:id] || params[:email]
        path = if audience_id
                 "audiences/#{audience_id}/contacts/#{contact_id}"
               else
                 "contacts/#{contact_id}"
               end
        Resend::Request.new(path, {}, "get").perform
      end

      #
      # List contacts
      #
      # @param params [Hash] optional parameters including pagination
      # @option params [String] :audience_id optional audience id to scope the operation
      # @option params [Integer] :limit number of records to return
      # @option params [String] :cursor pagination cursor
      #
      # @example List all contacts
      #   Resend::Contacts.list
      #
      # @example List contacts with pagination
      #   Resend::Contacts.list(limit: 10)
      #
      # @example List contacts scoped to an audience
      #   Resend::Contacts.list(audience_id: "aud_456", limit: 10)
      #
      # https://resend.com/docs/api-reference/contacts/list-contacts
      def list(params = {})
        audience_id = params[:audience_id]
        path = if audience_id
                 Resend::PaginationHelper.build_paginated_path("audiences/#{audience_id}/contacts", params)
               else
                 Resend::PaginationHelper.build_paginated_path("contacts", params)
               end
        Resend::Request.new(path, {}, "get").perform
      end

      #
      # Remove a contact
      #
      # @param params [Hash] the parameters
      # @option params [String] :id either the contact id or contact email (required)
      # @option params [String] :audience_id optional audience id to scope the operation
      #
      # @example Remove contact by ID
      #   Resend::Contacts.remove(id: "contact_123")
      #
      # @example Remove contact scoped to an audience
      #   Resend::Contacts.remove(id: "contact_123", audience_id: "aud_456")
      #
      # https://resend.com/docs/api-reference/contacts/delete-contact
      def remove(params = {})
        raise ArgumentError, "Missing `id` or `email` field" if params[:id].nil? && params[:email].nil?

        audience_id = params[:audience_id]
        contact_id = params[:id] || params[:email]
        path = if audience_id
                 "audiences/#{audience_id}/contacts/#{contact_id}"
               else
                 "contacts/#{contact_id}"
               end
        Resend::Request.new(path, {}, "delete").perform
      end

      #
      # Update a contact
      #
      # @param params [Hash] the contact params
      # https://resend.com/docs/api-reference/contacts/update-contact
      def update(params)
        raise ArgumentError, "Missing `id` or `email` field" if params[:id].nil? && params[:email].nil?

        contact_id = params[:id] || params[:email]
        if params[:audience_id]
          path = "audiences/#{params[:audience_id]}/contacts/#{contact_id}"
          # Audience-scoped contacts don't support properties
          payload = params.reject { |key, _| key == :properties }
        else
          path = "contacts/#{contact_id}"
          payload = params
        end
        Resend::Request.new(path, payload, "patch").perform
      end
    end
  end
end
