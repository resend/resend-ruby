# frozen_string_literal: true

module Resend
  # logs api wrapper
  module Logs
    class << self
      # https://resend.com/docs/api-reference/logs/retrieve-log
      def get(log_id = "")
        path = "logs/#{log_id}"
        Resend::Request.new(path, {}, "get").perform
      end

      # https://resend.com/docs/api-reference/logs/list-logs
      def list(params = {})
        path = Resend::PaginationHelper.build_paginated_path("logs", params)
        Resend::Request.new(path, {}, "get").perform
      end
    end
  end
end
