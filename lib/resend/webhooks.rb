# frozen_string_literal: true

module Resend
  # The Webhooks module provides methods for managing webhooks via the Resend API.
  # Webhooks allow you to receive real-time notifications about email events.
  #
  # @example Create a webhook
  #   Resend::Webhooks.create(
  #     endpoint: "https://webhook.example.com/handler",
  #     events: ["email.sent", "email.delivered", "email.bounced"]
  #   )
  #
  # @example List all webhooks
  #   Resend::Webhooks.list
  #
  # @example Retrieve a specific webhook
  #   Resend::Webhooks.get("4dd369bc-aa82-4ff3-97de-514ae3000ee0")
  #
  # @example Update a webhook
  #   Resend::Webhooks.update(
  #     webhook_id: "430eed87-632a-4ea6-90db-0aace67ec228",
  #     endpoint: "https://new-webhook.example.com/handler",
  #     events: ["email.sent", "email.delivered"],
  #     status: "enabled"
  #   )
  #
  # @example Delete a webhook
  #   Resend::Webhooks.remove("4dd369bc-aa82-4ff3-97de-514ae3000ee0")
  module Webhooks
    class << self
      # Create a new webhook to receive real-time notifications about email events
      #
      # @param params [Hash] The webhook parameters
      # @option params [String] :endpoint The URL where webhook events will be sent (required)
      # @option params [Array<String>] :events Array of event types to subscribe to (required)
      #
      # @return [Hash] The webhook object containing id, object type, and signing_secret
      #
      # @example
      #   Resend::Webhooks.create(
      #     endpoint: "https://webhook.example.com/handler",
      #     events: ["email.sent", "email.delivered", "email.bounced"]
      #   )
      def create(params = {})
        path = "webhooks"
        Resend::Request.new(path, params, "post").perform
      end

      # Retrieve a list of webhooks for the authenticated user
      #
      # @param params [Hash] The pagination parameters
      # @option params [Integer] :limit Number of webhooks to retrieve (max: 100, min: 1)
      # @option params [String] :after The ID after which to retrieve more webhooks (for pagination)
      # @option params [String] :before The ID before which to retrieve more webhooks (for pagination)
      #
      # @return [Hash] A paginated list of webhook objects
      #
      # @example
      #   Resend::Webhooks.list
      #
      # @example With pagination
      #   Resend::Webhooks.list(limit: 20, after: "4dd369bc-aa82-4ff3-97de-514ae3000ee0")
      def list(params = {})
        path = Resend::PaginationHelper.build_paginated_path("webhooks", params)
        Resend::Request.new(path, {}, "get").perform
      end

      # Retrieve a single webhook for the authenticated user
      #
      # @param webhook_id [String] The webhook ID
      #
      # @return [Hash] The webhook object with full details
      #
      # @example
      #   Resend::Webhooks.get("4dd369bc-aa82-4ff3-97de-514ae3000ee0")
      def get(webhook_id = "")
        path = "webhooks/#{webhook_id}"
        Resend::Request.new(path, {}, "get").perform
      end

      # Update an existing webhook configuration
      #
      # @param params [Hash] The webhook update parameters
      # @option params [String] :webhook_id The webhook ID (required)
      # @option params [String] :endpoint The URL where webhook events will be sent
      # @option params [Array<String>] :events Array of event types to subscribe to
      # @option params [String] :status The webhook status ("enabled" or "disabled")
      #
      # @return [Hash] The updated webhook object
      #
      # @example
      #   Resend::Webhooks.update(
      #     webhook_id: "430eed87-632a-4ea6-90db-0aace67ec228",
      #     endpoint: "https://new-webhook.example.com/handler",
      #     events: ["email.sent", "email.delivered"],
      #     status: "enabled"
      #   )
      def update(params = {})
        webhook_id = params.delete(:webhook_id)
        path = "webhooks/#{webhook_id}"
        Resend::Request.new(path, params, "patch").perform
      end

      # Remove an existing webhook
      #
      # @param webhook_id [String] The webhook ID
      #
      # @return [Hash] Confirmation object with id, object type, and deleted status
      #
      # @example
      #   Resend::Webhooks.remove("4dd369bc-aa82-4ff3-97de-514ae3000ee0")
      def remove(webhook_id = "")
        path = "webhooks/#{webhook_id}"
        Resend::Request.new(path, {}, "delete").perform
      end
    end
  end
end
