# frozen_string_literal: true

module Resend
  # Module responsible for wrapping email sending API
  module Emails
    class << self
      # Sends or schedules an email.
      # see more: https://resend.com/docs/api-reference/send-email
      def send(params)
        path = "emails"
        Resend::Request.new(path, params, "post").perform
      end

      # Retrieve a single email.
      # see more: https://resend.com/docs/api-reference/emails/retrieve-email
      def get(email_id = "")
        path = "emails/#{email_id}"
        Resend::Request.new(path, {}, "get").perform
      end

      # Update a scheduled email.
      # see more: https://resend.com/docs/api-reference/emails/update-email
      def update(params)
        path = "emails/#{params[:email_id]}"
        Resend::Request.new(path, params, "patch").perform
      end

      # Cancel a scheduled email.
      # see more: https://resend.com/docs/api-reference/emails/cancel-email
      def cancel(email_id = "")
        path = "emails/#{email_id}/cancel"
        Resend::Request.new(path, {}, "post").perform
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
