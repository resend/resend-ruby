# frozen_string_literal: true

module Resend
  # broadcasts api wrapper
  module Broadcasts
    class << self
      # https://resend.com/docs/api-reference/broadcasts/create-broadcast
      # @note Supports both segment_id and audience_id. At least one is required.
      #   audience_id is deprecated - use segment_id instead.
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
    end
  end
end
