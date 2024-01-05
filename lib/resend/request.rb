# frozen_string_literal: true

require "resend/version"
require "resend/errors"
require "httparty"

module Resend
  # This class is responsible for making the appropriate HTTP calls
  # and raising the specific errors based on the response.
  class Request
    BASE_URL = "https://api.resend.com/"

    attr_accessor :body, :verb

    def initialize(path = "", body = {}, verb = "POST")
      raise if Resend.api_key.nil?

      @path = path
      @body = body
      @verb = verb
      @headers = {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "User-Agent" => "resend-ruby:#{Resend::VERSION}",
        "Authorization" => "Bearer #{Resend.api_key}"
      }
    end

    # Performs the HTTP call
    def perform
      options = { headers: @headers }
      options[:body] = @body.to_json unless @body.empty?

      resp = HTTParty.send(@verb.to_sym, "#{BASE_URL}#{@path}", options)

      unless resend_call_sucess?(resp)
        handle_resend_error!(resp)

        # default to general resend error
        raise Resend::Error.new(nil, resp.code)
      end

      resp.transform_keys!(&:to_sym) if resp.respond_to?(:transform_keys) && !resp.body.empty?
      resp
    end

    private

    # Handles a Resend type of error.
    def handle_resend_error!(resp)
      code = resp.code
      body = nil
      body = resp.parsed_response["message"] if resp.respond_to?(:parsed_response)
      error = Resend::Error::ERRORS[code]
      raise(error.new(body, code)) if error
    end

    # Checks if the resend API response was successful.
    # Resend API returns 200 or 201 for successful calls.
    #
    # @param resp [HTTParty::Response]
    # @return [Boolean]
    def resend_call_sucess?(resp)
      resp.code == 200 || resp.code == 201
    end
  end
end
