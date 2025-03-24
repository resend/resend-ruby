# frozen_string_literal: true

module Resend
  # broadcasts api wrapper
  module Broadcasts
    class << self
      # https://resend.com/docs/api-reference/broadcasts/create-broadcast
      def create(params = {})
        path = "broadcasts"
        Resend::Request.new(path, params, "post").perform
      end

      # https://resend.com/docs/api-reference/broadcasts/update-broadcast
      def update(params = {})
        path = "broadcasts/#{params[:broadcast_id]}"
        Resend::Request.new(path, params, "patch").perform
      end

      # https://resend.com/docs/api-reference/broadcasts/send-broadcast
      def send(params = {})
        path = "broadcasts/#{params[:broadcast_id]}/send"
        Resend::Request.new(path, params, "post").perform
      end

      # https://resend.com/docs/api-reference/broadcasts/list-broadcasts
      def list
        path = "broadcasts"
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
