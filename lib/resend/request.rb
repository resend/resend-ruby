# frozen_string_literal: true

module Resend
  # This class is responsible for making the appropriate HTTP calls
  # and raising the specific errors based on the response.
  class Request
    BASE_URL = ENV["RESEND_BASE_URL"] || "https://api.resend.com/"

    attr_accessor :body, :verb, :options

    def initialize(path = "", body = {}, verb = "POST", options: {})
      raise if (api_key = Resend.api_key).nil?

      api_key = api_key.call if api_key.is_a?(Proc)

      @path = path
      @body = body
      @verb = verb
      @options = options
      @headers = {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "User-Agent" => "resend-ruby:#{Resend::VERSION}",
        "Authorization" => "Bearer #{api_key}"
      }

      set_idempotency_key
    end

    # Performs the HTTP call
    def perform
      options = build_request_options
      resp = HTTParty.send(@verb.to_sym, "#{BASE_URL}#{@path}", options)

      check_json!(resp)
      process_response(resp)
    end

    def handle_error!(resp)
      code = resp[:statusCode]
      body = resp[:message]

      # get error from the known list of errors
      error = Resend::Error::ERRORS[code]
      raise(error.new(body, code)) if error

      # Raise generic Resend error when the error code is not part of the known errors
      raise Resend::Error.new(body, code)
    end

    private

    def build_request_options
      options = { headers: @headers }

      if get_request_with_query?
        options[:query] = @body
      elsif !@body.empty?
        options[:body] = @body.to_json
      end

      options
    end

    def get_request_with_query?
      @verb.downcase == "get" && !@body.empty?
    end

    def process_response(resp)
      resp.transform_keys!(&:to_sym) unless resp.body.empty?
      handle_error!(resp) if error_response?(resp)
      resp
    end

    def error_response?(resp)
      resp[:statusCode] && (resp[:statusCode] != 200 && resp[:statusCode] != 201)
    end

    def set_idempotency_key
      # Only set idempotency key if the verb is POST for now.
      #
      # Does not set it if the idempotency_key is nil or empty
      if @verb.downcase == "post" && (!@options[:idempotency_key].nil? && !@options[:idempotency_key].empty?)
        @headers["Idempotency-Key"] = @options[:idempotency_key]
      end
    end

    def check_json!(resp)
      if resp.body.is_a?(Hash)
        JSON.parse(resp.body.to_json)
      else
        JSON.parse(resp.body)
      end
    rescue JSON::ParserError, TypeError
      raise Resend::Error::InternalServerError.new("Resend API returned an unexpected response", nil)
    end
  end
end
