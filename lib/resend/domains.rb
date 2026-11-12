# frozen_string_literal: true

module Resend
  # domains api wrapper
  module Domains
    class << self
      # https://resend.com/docs/api-reference/domains/create-domain
      def create(params)
        path = "domains"
        Resend::Request.new(path, params, "post").perform
      end

      # Updates a domain. :forge_return_path moves the Forge return path
      # without starting verification, and composes with the other fields.
      #
      # https://resend.com/docs/api-reference/domains/update-domain
      def update(params)
        path = "domains/#{params[:id]}"
        Resend::Request.new(path, params, "patch").perform
      end

      # https://resend.com/docs/api-reference/domains/get-domain
      def get(domain_id = "")
        path = "domains/#{domain_id}"
        Resend::Request.new(path, {}, "get").perform
      end

      # https://resend.com/docs/api-reference/domains/list-domains
      def list(params = {})
        path = Resend::PaginationHelper.build_paginated_path("domains", params)
        Resend::Request.new(path, {}, "get").perform
      end

      # https://resend.com/docs/api-reference/domains/delete-domain
      def remove(domain_id = "")
        path = "domains/#{domain_id}"
        Resend::Request.new(path, {}, "delete").perform
      end

      # Triggers domain verification. Pass `scope: ["forge"]` to re-check only
      # the Forge record; without a scope the whole domain is verified.
      #
      # https://resend.com/docs/api-reference/domains/verify-domain
      def verify(domain_id = "", params = {})
        path = "domains/#{domain_id}/verify"
        Resend::Request.new(path, params.slice(:scope), "post").perform
      end
    end
  end
end
