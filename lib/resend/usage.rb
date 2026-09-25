# frozen_string_literal: true

module Resend
  # usage api wrapper
  module Usage
    class << self
      # https://resend.com/docs/api-reference/usage/get-usage
      def get
        path = "usage"
        Resend::Request.new(path, {}, "get").perform
      end
    end
  end
end
