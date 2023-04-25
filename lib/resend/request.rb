# frozen_string_literal: true

require "resend/version"
require "resend/errors"
require "httparty"

module Resend
  # This class is responsible for making the appropriate HTTP calls
  # and raising the specific errors based on the response.
  class Request
    BASE_URL = "https://api.resend.com/"

    attr_accessor :client, :body, :verb

    def initialize(client, path = "", body = {}, verb = "POST")
      @client = client
      @path = path
      @body = body
      @verb = verb
      @headers = {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "User-Agent" => "ruby:#{Resend::VERSION}",
        "Authorization" => "Bearer #{@client.api_key}"
      }
    end

    # Performs the HTTP call
    def perform
      options = {}
      options[:body] = @body.to_json
      options[:headers] = @headers
      resp = HTTParty.post("#{BASE_URL}#{@path}", options)
      resp.transform_keys!(&:to_sym)
      handle_error!(resp) if resp[:statusCode] && resp[:statusCode] != 200
      resp
    end

    # TODO: looks like the API changed how the errors are sent.
    def handle_error!(resp)
      code = resp[:statusCode]
      body = resp[:message]
      error = Resend::Error::ERRORS[code]
      raise(error.new(body, code)) if error
    end
  end
end
