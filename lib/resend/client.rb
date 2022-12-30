require_relative "./version"
require_relative "./errors"
require "httparty"

module Resend

  class Client
    BASE_URL = "https://api.klotty.com/".freeze

    attr_reader :api_key, :base_url, :timeout

    def initialize(api_key)
      raise ArgumentError.new("API Key is not a string") unless api_key.is_a?(String)
      @api_key = api_key
      @timeout = nil
    end

    def send_email(params)
      validate!(params)

      options = {
        headers: {
          'Content-Type' => 'application/json',
          "Accept" => "application/json",
          "User-Agent" => "ruby:#{Resend::VERSION}",
          "Authorization" => "Bearer #{@api_key}",
        },
        body: params.to_json
      }

      resp = HTTParty.post("#{BASE_URL}/email", options)
      resp.transform_keys!(&:to_sym)
      if not resp[:error].nil?
        handle_error!(resp[:error])
      end
      resp
    end

    private

    def validate!(params)
      raise ArgumentError.new("'to' should be an Array or String") unless params[:to].is_a?(String) or params[:to].is_a?(Array)
      raise ArgumentError.new("Argument 'to' is missing") if params[:to].nil?
      raise ArgumentError.new("'to' can not be empty") if params[:to].empty?

      raise ArgumentError.new("'from' should be a String") unless params[:from].is_a?(String)
      raise ArgumentError.new("Argument 'from' is missing") if params[:from].nil?
      raise ArgumentError.new("'from' can not be empty") if params[:from].empty?

      raise ArgumentError.new("'from' should be a String") unless params[:from].is_a?(String)
      raise ArgumentError.new("Argument 'subject' is missing") if params[:subject].nil?
      raise ArgumentError.new("'subject' can not be empty") if params[:subject].empty?

      raise ArgumentError.new("Argument 'text' and 'html' are missing") if params[:text].nil? and params[:html].nil?
    end

    def handle_error!(error)
      err = error.transform_keys(&:to_sym)
      raise Resend::ResendError.new(err[:message])
    end
  end
end