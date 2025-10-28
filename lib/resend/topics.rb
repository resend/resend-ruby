# frozen_string_literal: true

module Resend
  # Topics api wrapper
  module Topics
    class << self
      # https://resend.com/docs/api-reference/topics/create-topic
      def create(params = {})
        path = "topics"
        Resend::Request.new(path, params, "post").perform
      end

      # https://resend.com/docs/api-reference/topics/get-topic
      def get(topic_id = "")
        path = "topics/#{topic_id}"
        Resend::Request.new(path, {}, "get").perform
      end

      # https://resend.com/docs/api-reference/topics/update-topic
      def update(params = {})
        path = "topics/#{params[:topic_id]}"
        Resend::Request.new(path, params, "patch").perform
      end

      # https://resend.com/docs/api-reference/topics/list-topics
      def list(params = {})
        path = Resend::PaginationHelper.build_paginated_path("topics", params)
        Resend::Request.new(path, {}, "get").perform
      end

      # https://resend.com/docs/api-reference/topics/delete-topic
      def remove(topic_id = "")
        path = "topics/#{topic_id}"
        Resend::Request.new(path, {}, "delete").perform
      end
    end
  end
end
