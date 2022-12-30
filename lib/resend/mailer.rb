require "resend"

module Resend
  class Mailer
    IGNORED_HEADERS = %w[to from subject reply-to]

    attr_accessor :config, :settings

    def initialize(config)
      @config = config
      raise Resend::ResendError.new("Config requires api_key", @config) unless @config.has_key?(:api_key)
      @settings = { return_response: true } # avoids NilError exception
      @resend_client = Resend::Client.new config[:api_key]
    end

    def deliver!(mail)
      params = {
        from: mail[:from].to_s,
        to: mail.to,
        subject: mail.subject,
      }
      params[:cc] = mail[:cc] if mail[:cc].present?
      params[:bcc] = mail[:bcc] if mail[:bcc].present?
      params[:reply_to] = mail[:reply_to] if mail[:reply_to].present?
      params[:html] = mail.body.decoded

      resp = @resend_client.send_email(params)

      if resp[:error].nil? then
        mail.message_id = resp[:id]
      end

      resp
    end

    def resend_client
      @resend_client
    end
  end
end