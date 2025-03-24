# frozen_string_literal: true

module Resend
  # This class is responsible for making the appropriate HTTP calls
  # and raising the specific errors based on the response.
  class Request
    BASE_URL = ENV["RESEND_BASE_URL"] || "https://api.resend.com/"

    attr_accessor :body, :verb

    def initialize(path = "", body = {}, verb = "POST")
      raise if (api_key = Resend.api_key).nil?

      api_key = api_key.call if api_key.is_a?(Proc)

      @path = path
      @body = body
      @verb = verb
      @headers = {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "User-Agent" => "resend-ruby:#{Resend::VERSION}",
        "Authorization" => "Bearer #{api_key}"
      }
    end

    # Performs the HTTP call
    def perform
      options = {
        headers: @headers
      }

      options[:body] = @body.to_json unless @body.empty?

      resp = HTTParty.send(@verb.to_sym, "#{BASE_URL}#{@path}", options)

      check_json!(resp)

      resp.transform_keys!(&:to_sym) unless resp.body.empty?
      handle_error!(resp) if resp[:statusCode] && (resp[:statusCode] != 200 || resp[:statusCode] != 201)
      resp
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
