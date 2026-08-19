# frozen_string_literal: true

module Resend
  # Module responsible for wrapping email sending API
  module Emails
    class << self
      # Sends or schedules an email.
      # see more: https://resend.com/docs/api-reference/emails/send-email
      def send(params, options: {})
        path = "emails"
        Resend::Request.new(path, params, "post", options: options).perform
      end

      # Retrieve a single email.
      # see more: https://resend.com/docs/api-reference/emails/retrieve-email
      def get(email_id = "")
        path = "emails/#{email_id}"
        Resend::Request.new(path, {}, "get").perform
      end

      # Update a scheduled email.
      # see more: https://resend.com/docs/api-reference/emails/update-email
      def update(params)
        path = "emails/#{params[:email_id]}"
        Resend::Request.new(path, params, "patch").perform
      end

      # Cancel a scheduled email.
      # see more: https://resend.com/docs/api-reference/emails/cancel-email
      def cancel(email_id = "")
        path = "emails/#{email_id}/cancel"
        Resend::Request.new(path, {}, "post").perform
      end

      # Create a shareable link for a sent or received email.
      #
      # @param email_id [String] The email id (sent or received).
      # @param params [Hash] Optional parameters
      # @option params [String] :expires_in Human-readable duration (e.g. "10m", "2 hours",
      #   "1 day"). Defaults to "48h" and is capped at 48 hours.
      def share(email_id, params = {})
        path = "emails/#{email_id}/share"
        Resend::Request.new(path, params, "post").perform
      end

      # List emails with optional pagination.
      # see more: https://resend.com/docs/api-reference/emails/list-emails
      #
      # @param options [Hash] Optional parameters for pagination
      # @option options [Integer] :limit Maximum number of emails to return (1-100, default 20)
      # @option options [String] :after Cursor for pagination (newer emails)
      # @option options [String] :before Cursor for pagination (older emails)
      def list(options = {})
        path = "emails"

        # Build query parameters, filtering out nil values
        query_params = {}
        query_params[:limit] = options[:limit] if options[:limit]
        query_params[:after] = options[:after] if options[:after]
        query_params[:before] = options[:before] if options[:before]

        Resend::Request.new(path, query_params, "get").perform
      end
    end
  end
end
