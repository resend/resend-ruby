# frozen_string_literal: true

require "resend"

module Resend
  # Mailer class used by railtie
  class Mailer
    attr_accessor :config, :settings

    def initialize(config)
      @config = config
      raise Resend::ResendError.new("Config requires api_key", @config) unless @config.key?(:api_key)

      @settings = { return_response: true } # avoids NilError exception
      @resend_client = Resend::Client.new config[:api_key]
    end

    def deliver!(mail)
      params = build_resend_params(mail)
      resp = @resend_client.send_email(params)
      mail.message_id = resp[:id] if resp[:error].nil?
      resp
    end

    # rubocop:disable Metrics/AbcSize
    def build_resend_params(mail)
      params = {
        from: mail[:from].to_s,
        to: mail.to,
        subject: mail.subject
      }
      params[:cc] = mail[:cc].to_s if mail[:cc].present?
      params[:bcc] = mail[:bcc].to_s if mail[:bcc].present?
      params[:reply_to] = mail[:reply_to].to_s if mail[:reply_to].present?
      params[:html] = mail.body.decoded
      params
    end
    # rubocop:enable Metrics/AbcSize

    attr_reader :resend_client
  end
end
