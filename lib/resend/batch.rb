# frozen_string_literal: true

module Resend
  # Module responsible for wrapping Batch email sending API
  module Batch
    class << self
      # Send a batch of emails
      #
      # @param params [Array<Hash>] Array of email parameters (max 100 emails)
      # @param options [Hash] Additional options for the request
      # @option options [String] :idempotency_key Optional idempotency key
      # @option options [String] :batch_validation Batch validation mode: "strict" (default) or "permissive"
      #   - "strict": Entire batch fails if any email is invalid
      #   - "permissive": Sends valid emails and returns errors for invalid ones
      #
      # @return [Hash] Response with :data array and optional :errors array (in permissive mode)
      #
      # @example Send batch with strict validation (default)
      #   Resend::Batch.send([
      #     { from: "sender@example.com", to: ["recipient@example.com"], subject: "Hello", html: "<p>Hi</p>" }
      #   ])
      #
      # @example Send batch with permissive validation
      #   response = Resend::Batch.send(emails, options: { batch_validation: "permissive" })
      #   # response[:data] contains successful email IDs
      #   # response[:errors] contains validation errors with index and message
      #
      # https://resend.com/docs/api-reference/emails/send-batch-emails
      def send(params = [], options: {})
        path = "emails/batch"

        Resend::Request.new(path, params, "post", options: options).perform
      end
    end
  end
end
