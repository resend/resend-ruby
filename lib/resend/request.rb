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
        "User-Agent" => "ruby:#{Resend::VERSION}",
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
      resp.transform_keys!(&:to_sym) if !resp.body.empty? && resp.respond_to?(:transform_keys!)
      handle_error!(resp) if resp[:statusCode] && (resp[:statusCode] != 200 || resp[:statusCode] != 201)
      resp
    end

    def handle_error!(resp)
      code = resp[:statusCode]
      body = resp[:message]
      # 如果报这个错，其实邮件是发出去了
      return if body == "Something went wrong while creating log"
      error = Resend::Error::ERRORS[code]
      raise(error.new(body, code)) if error
    end
  end
end
