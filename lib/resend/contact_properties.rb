# frozen_string_literal: true

module Resend
  # Module for managing contact properties
  #
  # Contact properties allow you to store custom data about your contacts
  module ContactProperties
    class << self
      # Create a custom property for your contacts
      #
      # @param params [Hash] Parameters for creating a contact property
      # @option params [String] :key The property key (max 50 characters, alphanumeric and underscores only) (required)
      # @option params [String] :type The property type ('string' or 'number') (required)
      # @option params [String, Integer] :fallback_value The default value when property is not set (must match type)
      #
      # @return [Hash] Response containing the created contact property
      #
      # @example Create a string property
      #   Resend::ContactProperties.create({
      #     key: 'company_name',
      #     type: 'string',
      #     fallback_value: 'Acme Corp'
      #   })
      #
      # @example Create a number property
      #   Resend::ContactProperties.create({
      #     key: 'age',
      #     type: 'number',
      #     fallback_value: 0
      #   })
      def create(params)
        path = "contact-properties"
        Resend::Request.new(path, params, "post").perform
      end

      # Retrieve a contact property by its ID
      #
      # @param contact_property_id [String] The Contact Property ID
      #
      # @return [Hash] Response containing the contact property details
      #
      # @example Get a contact property
      #   Resend::ContactProperties.get('b6d24b8e-af0b-4c3c-be0c-359bbd97381e')
      def get(contact_property_id = "")
        path = "contact-properties/#{contact_property_id}"
        Resend::Request.new(path, {}, "get").perform
      end

      # Retrieve a list of contact properties
      #
      # @param params [Hash] Optional query parameters
      # @option params [Integer] :limit Number of contact properties to retrieve (1-100, default: 20)
      # @option params [String] :after The ID after which to retrieve more contact properties
      # @option params [String] :before The ID before which to retrieve more contact properties
      #
      # @return [Hash] Response containing list of contact properties
      #
      # @example List all contact properties
      #   Resend::ContactProperties.list
      #
      # @example List with pagination
      #   Resend::ContactProperties.list({ limit: 10, after: 'cursor_123' })
      def list(params = {})
        path = Resend::PaginationHelper.build_paginated_path("contact-properties", params)
        Resend::Request.new(path, {}, "get").perform
      end

      # Update an existing contact property
      #
      # Note: The 'key' and 'type' fields cannot be changed after creation
      #
      # @param params [Hash] Parameters for updating a contact property
      # @option params [String] :id The Contact Property ID (required)
      # @option params [String, Integer] :fallback_value The default value when property is not set
      #   (must match property type)
      #
      # @return [Hash] Response containing the updated contact property
      #
      # @example Update fallback value
      #   Resend::ContactProperties.update({
      #     id: 'b6d24b8e-af0b-4c3c-be0c-359bbd97381e',
      #     fallback_value: 'Example Company'
      #   })
      def update(params)
        raise ArgumentError, "Missing `id` field" if params[:id].nil?

        contact_property_id = params[:id]
        path = "contact-properties/#{contact_property_id}"
        Resend::Request.new(path, params, "patch").perform
      end

      # Remove an existing contact property
      #
      # @param contact_property_id [String] The Contact Property ID
      #
      # @return [Hash] Response containing the deleted property ID and confirmation
      #
      # @example Delete a contact property
      #   Resend::ContactProperties.remove('b6d24b8e-af0b-4c3c-be0c-359bbd97381e')
      def remove(contact_property_id = "")
        path = "contact-properties/#{contact_property_id}"
        Resend::Request.new(path, {}, "delete").perform
      end
    end
  end
end
