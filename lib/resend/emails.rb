# frozen_string_literal: true

require "resend/request"

module Resend
  # Module responsible for wrapping email sending API
  module Emails
    # send email functionality
    # https://resend.com/docs/api-reference/send-email
    def send_email(params)
      validate_email!(params)
      path = "/email"
      Resend::Request.new(self, path, params, "post").perform
    end

    private

    def validate_email!(params)
      validate_to_param!(params)
      validate_from_param!(params)
      validate_subject_param!(params)
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
  end
end
