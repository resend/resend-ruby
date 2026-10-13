# frozen_string_literal: true

module Resend
  # Inboxes api wrapper
  #
  # An inbox sends and receives email at an address on one of your domains.
  #
  # @example Create an inbox
  #   Resend::Inboxes.create(email_address: "support@acme.com", name: "Customer Support")
  #
  # @example Retrieve an inbox by ID or email address
  #   Resend::Inboxes.get("support@acme.com")
  module Inboxes
    class << self
      # Create an inbox
      #
      # The domain must belong to the team. Without `forwarding`, the domain must have receiving
      # enabled, with DKIM and SPF verified and the inbound MX record verified or pending. With
      # `forwarding` set to `true`, the domain only needs DKIM and SPF verified for sending, and
      # Resend generates a `receiving_address` on the team inbound domain. A team that has reached
      # the inbox limit of its plan gets a 403 validation_error. A blocked account gets a 451.
      #
      # @param params [Hash] the inbox parameters
      # @option params [String] :email_address the inbox email address on one of your domains (required)
      # @option params [String] :name internal name for the inbox, max 64 characters.
      #   Recipients do not see it. Defaults to `email_address`
      # @option params [String] :from_name the name recipients see when mail is sent from this inbox,
      #   max 78 characters. An empty string leaves it unset
      # @option params [Boolean] :forwarding when true, Resend provisions a receiving address so you can
      #   receive mail without adding an MX record. Defaults to false
      #
      # @return [Hash] the created inbox `object` and `id`
      #
      # https://resend.com/docs/api-reference/inboxes/create-inbox
      def create(params = {})
        Resend::Request.new("inboxes", params, "post").perform
      end

      # Retrieve a list of inboxes, newest first
      #
      # The list items carry fewer fields than a single inbox. Retrieve an inbox to get all its fields.
      # The `after` and `before` cursors take an inbox ID.
      #
      # @param params [Hash] the pagination parameters
      # @option params [Integer] :limit the maximum number of results to return
      # @option params [String] :after the cursor for pagination
      # @option params [String] :before the cursor for pagination
      #
      # https://resend.com/docs/api-reference/inboxes/list-inboxes
      def list(params = {})
        path = Resend::PaginationHelper.build_paginated_path("inboxes", params)
        Resend::Request.new(path, {}, "get").perform
      end

      # Retrieve a single inbox
      #
      # @param inbox_id [String] the inbox ID or the inbox email address, such as `support@acme.com`.
      #   An email address matches without case
      #
      # https://resend.com/docs/api-reference/inboxes/get-inbox
      def get(inbox_id = "")
        Resend::Request.new("inboxes/#{ERB::Util.url_encode(inbox_id)}", {}, "get").perform
      end

      # Update an existing inbox
      #
      # At least one of `name` or `from_name` is required.
      #
      # @param params [Hash] the update parameters
      # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
      # @option params [String] :name new internal name for the inbox, between 1 and 64 characters
      # @option params [String] :from_name the name recipients see when mail is sent from this inbox,
      #   max 78 characters. An empty string removes it
      #
      # @return [Hash] the updated inbox `object` and `id`
      #
      # https://resend.com/docs/api-reference/inboxes/update-inbox
      def update(params = {})
        raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?

        payload = params.except(:inbox_id)
        Resend::Request.new("inboxes/#{params[:inbox_id]}", payload, "patch").perform
      end

      # Remove an existing inbox
      #
      # @param inbox_id [String] the inbox ID. An email address is not accepted
      #
      # https://resend.com/docs/api-reference/inboxes/delete-inbox
      def remove(inbox_id = "")
        Resend::Request.new("inboxes/#{inbox_id}", {}, "delete").perform
      end
    end
  end
end
