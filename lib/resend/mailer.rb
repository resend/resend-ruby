# frozen_string_literal: true

require "resend"

module Resend
  # Mailer class used by railtie
  class Mailer
    attr_accessor :config

    def initialize(config)
      @config = config
      raise Resend::Error.new("Make sure your api is set", @config) unless Resend.api_key
    end

    def deliver!(mail)
      params = build_resend_params(mail)
      resp = Resend::Emails.send(params)
      mail.message_id = resp[:id] if resp[:error].nil?
      resp
    end

    def build_resend_params(mail)
      params = {
        from: get_from(mail.from),
        to: mail.to,
        subject: mail.subject
      }
      params.merge!(get_addons(mail))
      params[:attachments] = get_attachments(mail) if mail.attachments.present?
      params.merge!(get_contents(mail))
      params
    end

    def get_addons(mail)
      params = {}
      params[:cc] = mail.cc if mail.cc.present?
      params[:bcc] = mail.bcc if mail.bcc.present?
      params[:reply_to] = mail.reply_to if mail.reply_to.present?
      params
    end

    def get_contents(mail)
      params = {}
      case mail.mime_type
      when "text/plain"
        params[:text] = mail.body.decoded
      when "text/html"
        params[:html] = mail.body.decoded
      when "multipart/alternative", "multipart/mixed", "multipart/related"
        params[:text] = mail.text_part.decoded if mail.text_part
        params[:html] = mail.html_part.decoded if mail.html_part
      end
      params
    end

    def get_from(input)
      return input.first if input.is_a? Array

      input
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
