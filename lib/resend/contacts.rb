# frozen_string_literal: true

module Resend
  # Contacts api wrapper
  module Contacts
    class << self
      # https://resend.com/docs/api-reference/contacts/create-contact
      def create(params)
        path = "audiences/#{params[:audience_id]}/contacts"
        Resend::Request.new(path, params, "post").perform
      end

      # https://resend.com/docs/api-reference/contacts/get-contact
      def get(audience_id, id)
        path = "audiences/#{audience_id}/contacts/#{id}"
        Resend::Request.new(path, {}, "get").perform
      end

      #
      # List contacts in an audience
      #
      # @param audience_id [String] the audience id
      # https://resend.com/docs/api-reference/contacts/list-contacts
      def list(audience_id)
        path = "audiences/#{audience_id}/contacts"
        Resend::Request.new(path, {}, "get").perform
      end

      #
      # Remove a contact from an audience
      #
      # @param audience_id [String] the audience id
      # @param contact_id [String] either the contact id or contact email
      #
      # see also: https://resend.com/docs/api-reference/contacts/delete-contact
      def remove(audience_id, contact_id)
        path = "audiences/#{audience_id}/contacts/#{contact_id}"
        Resend::Request.new(path, {}, "delete").perform
      end

      #
      # Update a contact
      #
      # @param params [Hash] the contact params
      # https://resend.com/docs/api-reference/contacts/update-contact
      def update(params)
        raise ArgumentError, "id or email is required" if params[:id].nil? && params[:email].nil?

        path = "audiences/#{params[:audience_id]}/contacts/#{params[:id] || params[:email]}"
        Resend::Request.new(path, params, "patch").perform
      end
    end
  end
end
