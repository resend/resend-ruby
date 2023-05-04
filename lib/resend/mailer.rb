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
    end

    def deliver!(mail)
      params = build_resend_params(mail)
      resp = Resend::Emails.send(params)
      mail.message_id = resp[:id] if resp[:error].nil?
      resp
    end

    # rubocop:disable Metrics/AbcSize
    def build_resend_params(mail)
      params = {
        from: get_from(mail.from),
        to: mail.to,
        subject: mail.subject
      }
      params[:cc] = mail.cc if mail.cc.present?
      params[:bcc] = mail.bcc if mail.bcc.present?
      params[:reply_to] = mail.reply_to if mail.reply_to.present?
      params[:attachments] = get_attachments(mail) if mail.attachments.present?
      params[:html] = get_contents(mail)
      params
    end
    # rubocop:enable Metrics/AbcSize

    def get_from(input)
      return input.first if input.is_a? Array

      input
    end

    def get_contents(mail)
      case mail.mime_type
      when "text/plain", "text/html"
        mail.body.decoded
      when "multipart/alternative", "multipart/mixed", "multipart/related"
        return mail.text_part.decoded if mail.text_part
        return mail.html_part.decoded if mail.html_part
      end
    end

    def get_attachments(mail)
      attachments = []
      mail.attachments.each do |part|
        attachment = {
          filename: part.filename,
          content: part.body.decoded.bytes
        }
        attachments.append(attachment)
      end
      attachments
    end
  end
end
