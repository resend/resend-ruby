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

      # https://resend.com/docs/api-reference/api-keys/list-api-keys
      def list
        path = "domains"
        Resend::Request.new(path, {}, "get").perform
      end

      # https://resend.com/docs/api-reference/domains/delete-domain
      def remove(domain_id = "")
        path = "domains/#{domain_id}"
        Resend::Request.new(path, {}, "delete").perform
      end

      # https://resend.com/docs/api-reference/domains/verify-domain
      def verify(domain_id = "")
        path = "domains/#{domain_id}/verify"
        Resend::Request.new(path, {}, "post").perform
      end
    end
  end
end
