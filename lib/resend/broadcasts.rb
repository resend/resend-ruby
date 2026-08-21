# frozen_string_literal: true

module Resend
  # broadcasts api wrapper
  module Broadcasts
    class << self
      # https://resend.com/docs/api-reference/broadcasts/create-broadcast
      # @note Supports both segment_id and audience_id. At least one is required.
      #   audience_id is deprecated - use segment_id instead.
      # @note When send: true is passed, the broadcast is sent immediately instead of
      #   creating a draft. When using send: true, you can also include scheduled_at
      #   to schedule the broadcast. Passing scheduled_at without send: true is an error.
      def create(params = {})
        if params[:audience_id] && !params[:segment_id]
          warn "[DEPRECATION] Using audience_id in broadcasts is deprecated. Use segment_id instead."
        end
        path = "broadcasts"
        Resend::Request.new(path, params, "post").perform
      end

      # https://resend.com/docs/api-reference/broadcasts/update-broadcast
      # @note Supports both segment_id and audience_id. At least one may be required.
      #   audience_id is deprecated - use segment_id instead.
      def update(params = {})
        if params[:audience_id] && !params[:segment_id]
          warn "[DEPRECATION] Using audience_id in broadcasts is deprecated. Use segment_id instead."
        end
        path = "broadcasts/#{params[:broadcast_id]}"
        Resend::Request.new(path, params, "patch").perform
      end

      # https://resend.com/docs/api-reference/broadcasts/send-broadcast
      def send(params = {})
        path = "broadcasts/#{params[:broadcast_id]}/send"
        Resend::Request.new(path, params, "post").perform
      end

      # https://resend.com/docs/api-reference/broadcasts/list-broadcasts
      def list(params = {})
        path = Resend::PaginationHelper.build_paginated_path("broadcasts", params)
        Resend::Request.new(path, {}, "get").perform
      end

      def cancel(broadcast_id = "")
        path = "broadcasts/#{broadcast_id}/cancel"
        Resend::Request.new(path, {}, "post").perform
      end

      # https://resend.com/docs/api-reference/broadcasts/delete-broadcast
      def remove(broadcast_id = "")
        path = "broadcasts/#{broadcast_id}"
        Resend::Request.new(path, {}, "delete").perform
      end

      # https://resend.com/docs/api-reference/broadcasts/get-broadcast
      def get(broadcast_id = "")
        path = "broadcasts/#{broadcast_id}"
        Resend::Request.new(path, {}, "get").perform
      end

      # https://resend.com/docs/api-reference/broadcasts/list-broadcast-recipients
      # @param broadcast_id [String] the broadcast id
      # @param params [Hash] the parameters
      # @option params [String] :type the recipient event type to filter by (required):
      #   sent, delivered, opened, clicked, bounced, complained, unsubscribed, suppressed
      # @option params [String] :email filter recipients by email address (optional)
      # @option params [String] :bounce_type filter bounced recipients by bounce type (optional,
      #   only valid when type is bounced): permanent, transient, undetermined
      # @option params [Integer] :limit the maximum number of results to return (optional)
      # @option params [String] :after the cursor for pagination (optional)
      # @option params [String] :before the cursor for pagination (optional)
      def recipients(broadcast_id = "", params = {})
        raise ArgumentError, "type is required" if params[:type].nil?

        base_path = "broadcasts/#{broadcast_id}/recipients"
        path = Resend::PaginationHelper.build_paginated_path(base_path, params)
        Resend::Request.new(path, {}, "get").perform
      end
    end
  end
end
