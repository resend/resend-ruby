# frozen_string_literal: true

require "mail"

module Resend
  module ActionMailbox
    # Rebuilds the full RFC 822 source of a received email so it can be ingested
    # by Action Mailbox.
    #
    # Resend's +email.received+ webhook only carries metadata, so the message is
    # fetched from the Received Emails API. When the API exposes a raw message
    # download it is used as-is; otherwise the message is reconstructed as a
    # Mail::Message from its parts, downloading each attachment through the
    # attachments API.
    class MessageBuilder
      # Headers that describe the reconstructed MIME structure and therefore
      # cannot be copied verbatim from the original message.
      STRUCTURAL_HEADERS = %w[content-type content-transfer-encoding mime-version].freeze

      # Envelope fields that are set from the API response when the original
      # header of the same name is not available.
      ENVELOPE_FIELDS = %i[from to cc bcc reply_to subject message_id].freeze

      # @param email_id [String] The ID of the received email
      def initialize(email_id)
        @email_id = email_id
      end

      # @return [String] the full RFC 822 source of the received email
      def raw_email
        raw_download || rebuild_message.to_s
      end

      private

      def email
        @email ||= Resend::Emails::Receiving.get(@email_id, html_format: "cid")
      end

      def raw_download
        url = fetch(email[:raw], "download_url") unless blank?(email[:raw])
        download(url) unless blank?(url)
      end

      def rebuild_message
        Mail.new.tap do |mail|
          copy_headers(mail)
          copy_envelope(mail)
          add_bodies(mail)
          add_attachments(mail)
        end
      end

      def copy_headers(mail)
        (email[:headers] || {}).each do |name, value|
          next if STRUCTURAL_HEADERS.include?(name.to_s.downcase)

          Array(value).each { |val| mail.header[name.to_s] = val }
        end
      end

      def copy_envelope(mail)
        ENVELOPE_FIELDS.each do |field|
          value = email[field]
          next if blank?(value) || mail.header[field.to_s.tr("_", "-")]

          mail.public_send("#{field}=", value)
        end

        mail.date ||= email[:created_at]

        expose_bcc(mail)
        copy_received_for(mail)
      end

      # Mail omits Bcc when serializing a message by default, but Action Mailbox
      # needs it to route the email.
      def expose_bcc(mail)
        bcc = mail.header["bcc"]
        bcc.include_in_headers = true if bcc.respond_to?(:include_in_headers)
      end

      # Preserve the addresses this email was received for (e.g. through a
      # forwarding rule) so Action Mailbox can route on them.
      def copy_received_for(mail)
        Array(email[:received_for]).each { |address| mail.header["X-Original-To"] = address }
      end

      def add_bodies(mail)
        html = presence(email[:html])
        text = presence(email[:text])

        if html
          mail.text_part = build_part("text/plain", text) if text
          mail.html_part = build_part("text/html", html)
        elsif text
          mail.content_type "text/plain; charset=UTF-8"
          mail.body text
        end
      end

      def build_part(mime_type, content)
        Mail::Part.new(content_type: "#{mime_type}; charset=UTF-8", body: content)
      end

      def add_attachments(mail)
        Array(email[:attachments]).each { |meta| add_attachment(mail, meta) }
      end

      def add_attachment(mail, meta)
        details = Resend::Emails::Receiving::Attachments.get(email_id: @email_id, id: fetch(meta, "id"))
        filename = fetch(meta, "filename") || details[:filename]

        mail.attachments[filename] = {
          mime_type: fetch(meta, "content_type") || details[:content_type],
          content: download(details[:download_url])
        }

        decorate_attachment(mail.attachments.last, meta)
      end

      def decorate_attachment(part, meta)
        content_id = fetch(meta, "content_id")
        part.content_id = normalize_content_id(content_id) unless blank?(content_id)

        return unless fetch(meta, "content_disposition") == "inline"

        part.content_disposition = "inline; filename=\"#{part.filename}\""
      end

      def normalize_content_id(content_id)
        content_id.start_with?("<") ? content_id : "<#{content_id}>"
      end

      def download(url)
        response = HTTParty.get(url)

        unless response.code == 200
          raise Resend::Error::ServerError.new(
            "Failed to download received email content (HTTP #{response.code})", response.code
          )
        end

        response.body
      end

      # Nested objects come back from the API with string keys, but hand-built
      # hashes (tests, console usage) often use symbols. Accept both.
      def fetch(hash, key)
        hash[key] || hash[key.to_sym]
      end

      def presence(value)
        value unless blank?(value)
      end

      def blank?(value)
        value.nil? || (value.respond_to?(:empty?) && value.empty?)
      end
    end
  end
end
