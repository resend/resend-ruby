# frozen_string_literal: true

require_relative "./version"
require_relative "./errors"
require "httparty"

module Resend
  # Main Resent client class, most methods should live here.
  class Client
    BASE_URL = "https://api.klotty.com/"

    attr_reader :api_key, :base_url, :timeout

    def initialize(api_key)
      raise ArgumentError, "API Key is not a string" unless api_key.is_a?(String)

      @api_key = api_key
      @timeout = nil
    end

    def send_email(params)
      validate!(params)

      options = {
        headers: {
          "Content-Type" => "application/json",
          "Accept" => "application/json",
          "User-Agent" => "ruby:#{Resend::VERSION}",
          "Authorization" => "Bearer #{@api_key}"
        },
        body: params.to_json
      }

      resp = HTTParty.post("#{BASE_URL}/email", options)
      resp.transform_keys!(&:to_sym)
      handle_error!(resp[:error]) unless resp[:error].nil?
      resp
    end

    private

    def validate!(params)
      validate_to_param!
      validate_from_param!
      validate_subject_param!
      raise ArgumentError, "Argument 'text' and 'html' are missing" if params[:text].nil? && params[:html].nil?
    end

    def validate_to_param!(params)
      unless params[:to].is_a?(String) || params[:to].is_a?(Array)
        raise ArgumentError,
              "'to' should be an Array or String"
      end
      raise ArgumentError, "Argument 'to' is missing" if params[:to].nil?
      raise ArgumentError, "'to' can not be empty" if params[:to].empty?
    end

    def validate_from_param!(params)
      raise ArgumentError, "'from' should be a String" unless params[:from].is_a?(String)
      raise ArgumentError, "Argument 'from' is missing" if params[:from].nil?
      raise ArgumentError, "'from' can not be empty" if params[:from].empty?
      raise ArgumentError, "'from' should be a String" unless params[:from].is_a?(String)
    end

    def validate_subject_param!(params)
      raise ArgumentError, "Argument 'subject' is missing" if params[:subject].nil?
      raise ArgumentError, "'subject' can not be empty" if params[:subject].empty?
    end

    def handle_error!(error)
      err = error.transform_keys(&:to_sym)
      raise Resend::ResendError, err[:message]
    end
  end
end
