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
      options = {
        headers: @headers
      }

      options[:body] = @body.to_json unless @body.empty?
      resp = HTTParty.send(@verb.to_sym, "#{BASE_URL}#{@path}", options)
      resp.transform_keys!(&:to_sym) unless resp.body.empty?
      handle_error!(resp) if resp[:statusCode] && (resp[:statusCode] != 200 || resp[:statusCode] != 201)
      resp
    end

    def handle_error!(resp)
      code = resp[:statusCode]
      body = resp[:message]
      error = Resend::Error::ERRORS[code]
      raise(error.new(body, code)) if error
    end
  end
end
