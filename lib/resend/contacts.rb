# frozen_string_literal: true

module Resend
  # Contacts api wrapper
  module Contacts
    class << self
      # https://resend.com/docs/api-reference/contacts/create-contact
      def create(params)
        path = if params[:audience_id]
                 "audiences/#{params[:audience_id]}/contacts"
               else
                 "contacts"
               end
        Resend::Request.new(path, params, "post").perform
      end

      #
      # Retrieves a contact from an audience
      #
      # @overload get(audience_id, id)
      #   Original signature for backward compatibility
      #   @param audience_id [String] the audience id
      #   @param id [String] either the contact id or contact's email
      #
      # @overload get(id, audience_id: nil)
      #   New signature with optional audience_id
      #   @param id [String] either the contact id or contact's email
      #   @param audience_id [String] optional audience id to scope the operation
      #
      # https://resend.com/docs/api-reference/contacts/get-contact
      def get(audience_id_or_id, id_or_options = nil, **kwargs)
        # Handle both calling styles for backward compatibility
        if id_or_options.is_a?(String) || (id_or_options.nil? && kwargs.empty?)
          # Old style: get(audience_id, contact_id) or get(audience_id, email)
          # OR new style without audience_id: get(contact_id)
          audience_id = id_or_options.nil? ? nil : audience_id_or_id
          contact_id = id_or_options.nil? ? audience_id_or_id : id_or_options
        else
          # New style with keyword arg: get(contact_id, audience_id: 'xxx')
          contact_id = audience_id_or_id
          audience_id = kwargs[:audience_id]
        end

        path = if audience_id
                 "audiences/#{audience_id}/contacts/#{contact_id}"
               else
                 "contacts/#{contact_id}"
               end
        Resend::Request.new(path, {}, "get").perform
      end

      #
      # List contacts in an audience
      #
      # @overload list(audience_id, params = {})
      #   Original signature for backward compatibility
      #   @param audience_id [String] the audience id
      #   @param params [Hash] optional pagination parameters
      #
      # @overload list(params = {})
      #   New signature with optional audience_id in params
      #   @param params [Hash] optional parameters including audience_id and pagination
      #
      # https://resend.com/docs/api-reference/contacts/list-contacts
      def list(audience_id_or_params = {}, params = {})
        # Handle both calling styles for backward compatibility
        if audience_id_or_params.is_a?(String)
          # Old style: list(audience_id, params)
          audience_id = audience_id_or_params
          query_params = params
        else
          # New style: list(params) or list(audience_id: 'xxx', limit: 10)
          audience_id = audience_id_or_params[:audience_id]
          query_params = audience_id_or_params
        end

        path = if audience_id
                 Resend::PaginationHelper.build_paginated_path("audiences/#{audience_id}/contacts", query_params)
               else
                 Resend::PaginationHelper.build_paginated_path("contacts", query_params)
               end
        Resend::Request.new(path, {}, "get").perform
      end

      #
      # Remove a contact from an audience
      #
      # @overload remove(audience_id, contact_id)
      #   Original signature for backward compatibility
      #   @param audience_id [String] the audience id
      #   @param contact_id [String] either the contact id or contact email
      #
      # @overload remove(contact_id, audience_id: nil)
      #   New signature with optional audience_id
      #   @param contact_id [String] either the contact id or contact email
      #   @param audience_id [String] optional audience id to scope the operation
      #
      # see also: https://resend.com/docs/api-reference/contacts/delete-contact
      def remove(audience_id_or_contact_id, contact_id_or_options = nil, **kwargs)
        # Handle both calling styles for backward compatibility
        if contact_id_or_options.is_a?(String) || (contact_id_or_options.nil? && kwargs.empty?)
          # Old style: remove(audience_id, contact_id) or new style: remove(contact_id)
          audience_id = contact_id_or_options.nil? ? nil : audience_id_or_contact_id
          contact_id = contact_id_or_options.nil? ? audience_id_or_contact_id : contact_id_or_options
        else
          # New style with keyword arg: remove(contact_id, audience_id: 'xxx')
          contact_id = audience_id_or_contact_id
          audience_id = kwargs[:audience_id]
        end

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
        raise ArgumentError, "id or email is required" if params[:id].nil? && params[:email].nil?

        contact_id = params[:id] || params[:email]
        path = if params[:audience_id]
                 "audiences/#{params[:audience_id]}/contacts/#{contact_id}"
               else
                 "contacts/#{contact_id}"
               end
        Resend::Request.new(path, params, "patch").perform
      end
    end
  end
end
