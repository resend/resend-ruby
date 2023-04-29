# frozen_string_literal: true

require "resend/request"

module Resend
  # Module responsible for wrapping email sending API
  module Emails
    # send email functionality
    # https://resend.com/docs/api-reference/send-email
    def send_email(params)
      path = "/email"
      Resend::Request.new(self, path, params, "post").perform
    end
  end
end
