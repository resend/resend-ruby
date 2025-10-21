# frozen_string_literal: true

module Resend
  # Templates api wrapper
  module Templates
    class << self
      # https://resend.com/docs/api-reference/templates/create-template
      def create(params = {})
        path = "templates"
        Resend::Request.new(path, params, "post").perform
      end

      # https://resend.com/docs/api-reference/templates/get-template
      def get(template_id = "")
        path = "templates/#{template_id}"
        Resend::Request.new(path, {}, "get").perform
      end
    end
  end
end
