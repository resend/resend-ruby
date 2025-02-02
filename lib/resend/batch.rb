# frozen_string_literal: true

module Resend
  # Module responsible for wrapping Batch email sending API
  module Batch
    class << self
      # https://resend.com/docs/api-reference/emails/send-batch-emails
      def send(params = [])
        path = "emails/batch"
        Resend::Request.new(path, params, "post").perform
      end
    end
  end
end
