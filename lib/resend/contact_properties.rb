# frozen_string_literal: true

module Resend
  # Contact Properties api wrapper
  module ContactProperties
    class << self
      # https://resend.com/docs/api-reference/contact-properties/create-contact-property
      def create(params)
        path = "contact-properties"
        Resend::Request.new(path, params, "post").perform
      end

      # https://resend.com/docs/api-reference/contact-properties/list-contact-properties
      def list(params = {})
        path = Resend::PaginationHelper.build_paginated_path("contact-properties", params)
        Resend::Request.new(path, {}, "get").perform
      end

      # https://resend.com/docs/api-reference/contact-properties/get-contact-property
      def get(id)
        path = "contact-properties/#{id}"
        Resend::Request.new(path, {}, "get").perform
      end

      # https://resend.com/docs/api-reference/contact-properties/update-contact-property
      def update(params)
        raise ArgumentError, "id is required" if params[:id].nil?

        path = "contact-properties/#{params[:id]}"
        Resend::Request.new(path, params, "patch").perform
      end

      # https://resend.com/docs/api-reference/contact-properties/delete-contact-property
      def remove(id)
        path = "contact-properties/#{id}"
        Resend::Request.new(path, {}, "delete").perform
      end
    end
  end
end
