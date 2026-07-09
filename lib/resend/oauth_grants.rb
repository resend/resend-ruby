# frozen_string_literal: true

module Resend
  # oauth grants api wrapper
  module OAuthGrants
    class << self
      # https://resend.com/docs/api-reference/oauth/list-grants
      def list(params = {})
        path = Resend::PaginationHelper.build_paginated_path("oauth/grants", params)
        Resend::Request.new(path, {}, "get").perform
      end

      # https://resend.com/docs/api-reference/oauth/revoke-grant
      def remove(oauth_grant_id = "")
        path = "oauth/grants/#{oauth_grant_id}"
        Resend::Request.new(path, {}, "delete").perform
      end
    end
  end
end
