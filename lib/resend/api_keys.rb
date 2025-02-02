# frozen_string_literal: true

module Resend
  # api keys api wrapper
  module ApiKeys
    class << self
      # https://resend.com/docs/api-reference/api-keys/create-api-key
      def create(params)
        path = "api-keys"
        Resend::Request.new(path, params, "post").perform
      end

      # https://resend.com/docs/api-reference/api-keys/list-api-keys
      def list
        path = "api-keys"
        Resend::Request.new(path, {}, "get").perform
      end

      # https://resend.com/docs/api-reference/api-keys/delete-api-key
      def remove(api_key_id = "")
        path = "api-keys/#{api_key_id}"
        Resend::Request.new(path, {}, "delete").perform
      end
    end
  end
end
