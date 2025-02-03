# frozen_string_literal: true

module Resend
  # Audiences api wrapper
  module Audiences
    class << self
      # https://resend.com/docs/api-reference/audiences/create-audience
      def create(params)
        path = "audiences"
        Resend::Request.new(path, params, "post").perform
      end

      # https://resend.com/docs/api-reference/audiences/get-audience
      def get(audience_id = "")
        path = "audiences/#{audience_id}"
        Resend::Request.new(path, {}, "get").perform
      end

      # https://resend.com/docs/api-reference/audiences/list-audiences
      def list
        path = "audiences"
        Resend::Request.new(path, {}, "get").perform
      end

      # https://resend.com/docs/api-reference/audiences/delete-audience
      def remove(audience_id = "")
        path = "audiences/#{audience_id}"
        Resend::Request.new(path, {}, "delete").perform
      end
    end
  end
end
