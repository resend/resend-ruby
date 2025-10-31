# frozen_string_literal: true

module Resend
  # Segments api wrapper
  module Segments
    class << self
      # https://resend.com/docs/api-reference/segments/create-segment
      def create(params)
        path = "segments"
        Resend::Request.new(path, params, "post").perform
      end

      # https://resend.com/docs/api-reference/segments/get-segment
      def get(segment_id = "")
        path = "segments/#{segment_id}"
        Resend::Request.new(path, {}, "get").perform
      end

      # https://resend.com/docs/api-reference/segments/list-segments
      def list(params = {})
        path = Resend::PaginationHelper.build_paginated_path("segments", params)
        Resend::Request.new(path, {}, "get").perform
      end

      # https://resend.com/docs/api-reference/segments/delete-segment
      def remove(segment_id = "")
        path = "segments/#{segment_id}"
        Resend::Request.new(path, {}, "delete").perform
      end
    end
  end
end
