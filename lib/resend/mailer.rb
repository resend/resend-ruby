# frozen_string_literal: true

require "resend"

module Resend
  # Mailer class used by railtie
  class Mailer
    attr_accessor :config, :settings

    def initialize(config)
      @config = config
      raise Resend::Error.new("Make sure your API Key is set", @config) unless Resend.api_key

      # avoids NilError exception
      @settings = { return_response: true }
    end

    #
    # Overwritten deliver! method
    #
    # @param Mail mail
    #
    # @return Object resend response
    #
    def deliver!(mail)
      params = build_resend_params(mail)
      resp = Resend::Emails.send(params)
      mail.message_id = resp[:id] if resp[:error].nil?
      resp
    end

    #
    # Builds the payload for sending
    #
    # @param Mail mail rails mail object
    #
    # @return Hash hash with all Resend params
    #
    def build_resend_params(mail)
      params = {
        from: get_from(mail),
        to: mail.to,
        subject: mail.subject
      }
      params.merge!(get_addons(mail))
      params.merge!(get_headers(mail))
      params.merge!(get_tags(mail))
      params[:attachments] = get_attachments(mail) if mail.attachments.present?
      params.merge!(get_contents(mail))
      params
    end

    #
    # Add custom headers fields
    #
    # @param Mail mail Rails Mail object
    #
    # @return Hash hash with headers param
    #
    def get_headers(mail)
      params = {}
      params[:headers] = mail[:headers].unparsed_value if mail[:headers].present?
      params
    end

    #
    # Add tags fields
    #
    # @param Mail mail Rails Mail object
    #
    # @return Hash hash with tags param
    #
    def get_tags(mail)
      params = {}
      params[:tags] = mail[:tags].unparsed_value if mail[:tags].present?
      params
    end

    #
    # Add cc, bcc, reply_to fields
    #
    # @param Mail mail Rails Mail Object
    #
    # @return Hash hash containing cc/bcc/reply_to attrs
    #
    def get_addons(mail)
      params = {}
      params[:cc] = mail.cc if mail.cc.present?
      params[:bcc] = mail.bcc if mail.bcc.present?
      params[:reply_to] = mail.reply_to if mail.reply_to.present?
      params
    end

    #
    # Gets the body of the email
    #
    # @param Mail mail Rails Mail Object
    #
    # @return Hash hash containing html/text or both attrs
    #
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

    #
    # Properly gets the `from` attr
    #
    # @param Mail input object
    #
    # @return String `from` string
    #
    def get_from(input)
      return input.from.first if input[:from].nil?

      from = input[:from].formatted
      return from.first if from.is_a? Array

      from.to_s
    end

    #
    # Handle attachments when present
    #
    # @return Array attachments array
    #
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
