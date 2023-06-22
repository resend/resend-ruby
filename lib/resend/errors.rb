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
    RateLimitExceededError = Class.new(ServerError)

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

    def initialize(msg, code = nil)
      super(msg)
      @code = code
    end
  end
end
