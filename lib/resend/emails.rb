# frozen_string_literal: true

require "resend/request"

module Resend
  # Module responsible for wrapping email sending API
  module Emails
    class << self
      # send email functionality
      # https://resend.com/docs/api-reference/send-email
      def send(params)
        path = "emails"
        Resend::Request.new(path, params, "post").perform
      end

      def get(email_id = "")
        path = "emails/#{email_id}"
        Resend::Request.new(path, {}, "get").perform
      end
    end

    # This method is kept here for backwards compatibility
    # Use Resend::Emails.send instead.
    def send_email(params)
      warn "[DEPRECATION] `send_email` is deprecated.  Please use `Resend::Emails.send` instead."
      Resend::Emails.send(params)
    end
  end
end
