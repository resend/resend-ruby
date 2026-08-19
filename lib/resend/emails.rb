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

      # Retrieve email metrics. (beta)
      # see more: https://resend.com/docs/api-reference/emails/metrics
      #
      # @param options [Hash] Optional parameters for filtering and shaping the metrics response
      # @option options [String] :start_date ISO 8601 date/datetime. Defaults to 6 days before :end_date
      # @option options [String] :end_date ISO 8601 date/datetime. Defaults to now
      # @option options [String] :timezone IANA timezone, e.g. "America/New_York". Defaults to "UTC"
      # @option options [String] :granularity Bucket size used when :period is in :dimensions.
      #   One of "hourly", "daily", "weekly", "monthly". Defaults to "daily"
      # @option options [Array<String>] :metrics Metrics to include. Defaults to all metrics.
      # @option options [Array<String>] :dimensions Dimensions to break down by: "period", "domain",
      #   "email", "broadcast". Defaults to none, which returns totals only.
      # @option options [Array<String>] :domain_id Restrict to these sending domain IDs (max 100)
      # @option options [Array<String>] :email_id Restrict to these email IDs (max 100)
      # @option options [Array<String>] :broadcast_id Restrict to these broadcast IDs (max 100)
      def metrics(options = {})
        path = "emails/metrics"
        Resend::Request.new(path, build_metrics_query(options), "get").perform
      end

      private

      # Builds the metrics query hash, filtering out nil values and joining
      # list-style params (metrics, dimensions, domain_id, email_id, broadcast_id)
      # into comma-separated strings as expected by the API.
      def build_metrics_query(options)
        query_params = {}

        %i[start_date end_date timezone granularity].each do |key|
          query_params[key] = options[key] if options[key]
        end

        %i[metrics dimensions domain_id email_id broadcast_id].each do |key|
          query_params[key] = Array(options[key]).join(",") if options[key]
        end

        query_params
      end
    end
  end
end
