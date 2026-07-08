# frozen_string_literal: true

require "openssl"
require "base64"

module Resend
  # The Webhooks module provides methods for managing webhooks via the Resend API.
  # Webhooks allow you to receive real-time notifications about email events.
  #
  # Default tolerance for timestamp validation (5 minutes)
  WEBHOOK_TOLERANCE_SECONDS = 300
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

      # Verify a webhook payload using HMAC-SHA256 signature validation
      # This validates that the webhook request came from Resend and hasn't been tampered with
      #
      # @param params [Hash] The webhook verification parameters
      # @option params [String] :payload The raw webhook payload body (required)
      # @option params [Hash] :headers The webhook headers containing svix-id, svix-timestamp,
      #   and svix-signature (required)
      # @option params [String] :webhook_secret The signing secret from webhook creation (required)
      #
      # @return [Boolean] true if verification succeeds
      # @raise [StandardError] If verification fails or required parameters are missing
      #
      # @example
      #   Resend::Webhooks.verify(
      #     payload: request.body.read,
      #     headers: {
      #       svix_id: "id_1234567890abcdefghijklmnopqrstuvwxyz",
      #       svix_timestamp: "1616161616",
      #       svix_signature: "v1,signature_here"
      #     },
      #     webhook_secret: "whsec_1234567890abcdez"
      #   )
      def verify(params = {})
        payload = params[:payload]
        headers = params[:headers] || {}
        webhook_secret = params[:webhook_secret]

        validate_required_params(payload, headers, webhook_secret)
        validate_timestamp(headers[:svix_timestamp])

        signed_content = "#{headers[:svix_id]}.#{headers[:svix_timestamp]}.#{payload}"
        decoded_secret = decode_secret(webhook_secret)
        expected_signature = generate_signature(decoded_secret, signed_content)

        verify_signature(headers[:svix_signature], expected_signature)
      end

      private

      # Validate required parameters
      def validate_required_params(payload, headers, webhook_secret)
        validate_payload(payload)
        validate_webhook_secret(webhook_secret)
        validate_headers(headers)
      end

      # Validate payload is present
      def validate_payload(payload)
        raise "payload cannot be empty" if payload.nil? || payload.empty?
      end

      # Validate webhook secret is present
      def validate_webhook_secret(webhook_secret)
        raise "webhook_secret cannot be empty" if webhook_secret.nil? || webhook_secret.empty?
      end

      # Validate required headers are present
      def validate_headers(headers)
        raise "svix-id header is required" if headers[:svix_id].nil? || headers[:svix_id].empty?
        raise "svix-timestamp header is required" if headers[:svix_timestamp].nil? || headers[:svix_timestamp].empty?
        raise "svix-signature header is required" if headers[:svix_signature].nil? || headers[:svix_signature].empty?
      end

      # Validate timestamp to prevent replay attacks
      def validate_timestamp(timestamp_header)
        timestamp = timestamp_header.to_i
        now = Time.now.to_i
        diff = now - timestamp

        return unless diff > WEBHOOK_TOLERANCE_SECONDS || diff < -WEBHOOK_TOLERANCE_SECONDS

        raise "Timestamp outside tolerance window: difference of #{diff} seconds"
      end

      # Decode the signing secret (strip whsec_ prefix and base64 decode)
      def decode_secret(webhook_secret)
        secret = webhook_secret.sub(/^whsec_/, "")
        Base64.strict_decode64(secret)
      rescue ArgumentError => e
        raise "Failed to decode webhook secret: #{e.message}"
      end

      # Verify signature using constant-time comparison
      def verify_signature(signature_header, expected_signature)
        signatures = signature_header.split(" ")
        signatures.each do |sig|
          parts = sig.split(",", 2)
          next if parts.length != 2

          received_signature = parts[1]
          return true if secure_compare(expected_signature, received_signature)
        end

        raise "No matching signature found"
      end

      # Generate HMAC-SHA256 signature and return it as base64
      def generate_signature(secret, content)
        digest = OpenSSL::HMAC.digest("sha256", secret, content)
        Base64.strict_encode64(digest)
      end

      # Constant-time string comparison to prevent timing attacks
      #
      # Note: We implement this manually for Ruby 2.7 compatibility.
      # Ruby 3.0+ could use OpenSSL.fixed_length_secure_compare instead.
      def secure_compare(str_a, str_b)
        return false if str_a.nil? || str_b.nil? || str_a.bytesize != str_b.bytesize

        bytes_a = str_a.unpack("C*")
        result = 0
        str_b.each_byte.with_index { |byte_b, i| result |= byte_b ^ bytes_a[i] }
        result.zero?
      end
    end
  end
end
