# frozen_string_literal: true

module Resend
  # Errors wrapper class
  # For more info: https://resend.com/docs/api-reference/error-codes
  class Error < StandardError
    # 4xx HTTP status code
    ClientError = Class.new(self)

    # 5xx HTTP status code
    ServerError = Class.new(self)

    # code 500
    InternalServerError = Class.new(ServerError)

    # code 422
    InvalidRequestError = Class.new(ServerError)

    # code 429
    class RateLimitExceededError < ServerError
      attr_reader :rate_limit_limit, :rate_limit_remaining, :rate_limit_reset, :retry_after

      def initialize(msg, code = nil, headers = {})
        super(msg, code, headers)
        @rate_limit_limit = headers["ratelimit-limit"]&.to_i
        @rate_limit_remaining = headers["ratelimit-remaining"]&.to_i
        @rate_limit_reset = headers["ratelimit-reset"]&.to_i
        @retry_after = headers["retry-after"]&.to_i
      end
    end

    # code 404
    NotFoundError = Class.new(ServerError)

    ERRORS = {
      401 => Resend::Error::InvalidRequestError,
      404 => Resend::Error::InvalidRequestError,
      422 => Resend::Error::InvalidRequestError,
      429 => Resend::Error::RateLimitExceededError,
      400 => Resend::Error::InvalidRequestError,
      500 => Resend::Error::InternalServerError
    }.freeze

    attr_reader :headers

    def initialize(msg, code = nil, headers = {})
      super(msg)
      @code = code
      @headers = headers
    end
  end
end
