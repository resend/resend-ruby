# frozen_string_literal: true

require "resend/request"
require "resend/errors"

module Resend
  # api keys api wrapper
  module ApiKeys
    ALLOWED_PERMISSIONS = %w[sending_access full_access].freeze

    # https://resend.com/docs/api-reference/api-keys/create-api-key
    def create_api_key(params)
      path = "/api-keys"
      Resend::Request.new(self, path, params, "post").perform
    end

    # https://resend.com/docs/api-reference/api-keys/list-api-keys
    def list_api_keys
      path = "/api-keys"
      Resend::Request.new(self, path, {}, "get").perform
    end

    # https://resend.com/docs/api-reference/api-keys/delete-api-key
    def delete_api_key(api_key_id = "")
      path = "/api-keys/#{api_key_id}"
      Resend::Request.new(self, path, {}, "delete").perform
    end
  end
end
