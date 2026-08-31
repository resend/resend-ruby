# frozen_string_literal: true

require "resend/action_mailbox/message_builder"

RSpec.describe Resend::ActionMailbox::MessageBuilder do
  let(:email_id) { "4ef9a417-02e9-4d39-ad75-9611e0fcc33c" }
  let(:builder) { described_class.new(email_id) }

  def http_response(code, body)
    double(code: code, body: body)
  end

  describe "#raw_email" do
    context "when a raw message download is available" do
      let(:raw_source) { "From: onboarding@resend.dev\r\nSubject: Raw\r\n\r\nHello" }

      before do
        allow(Resend::Emails::Receiving).to receive(:get).and_return(
          {
            id: email_id,
            raw: {
              "download_url" => "https://example.resend.com/receiving/raw/abc?Signature=sig",
              "expires_at" => "2026-04-03T23:13:42.674Z"
            },
            attachments: [{ "id" => "att_1", "filename" => "avatar.png" }]
          }
        )
        allow(HTTParty).to receive(:get)
          .with("https://example.resend.com/receiving/raw/abc?Signature=sig")
          .and_return(http_response(200, raw_source))
        allow(Resend::Emails::Receiving::Attachments).to receive(:get)
      end

      it "returns the raw message as-is" do
        expect(builder.raw_email).to eq(raw_source)
      end

      it "does not call the attachments API" do
        builder.raw_email
        expect(Resend::Emails::Receiving::Attachments).not_to have_received(:get)
      end

      it "requests the email with cid html format" do
        builder.raw_email
        expect(Resend::Emails::Receiving).to have_received(:get).with(email_id, html_format: "cid")
      end

      it "raises when the raw download fails" do
        allow(HTTParty).to receive(:get).and_return(http_response(403, "expired"))
        expect { builder.raw_email }.to raise_error(Resend::Error::ServerError, /HTTP 403/)
      end
    end

    context "when the message has to be reconstructed" do
      let(:png_content) { (+"\x89PNG\r\nfakeimage").force_encoding(Encoding::BINARY) }
      let(:pdf_content) { (+"%PDF-1.4 fakepdf").force_encoding(Encoding::BINARY) }

      let(:email_payload) do
        {
          object: "email",
          id: email_id,
          to: ["delivered@resend.dev"],
          from: "onboarding@resend.dev",
          created_at: "2026-04-03T22:13:42.674Z",
          subject: "Hello World",
          html: "<p>Hi <img src=\"cid:img001\"></p>",
          html_format: "cid",
          text: "Hi",
          headers: {
            "from" => "Acme <onboarding@resend.dev>",
            "date" => "Fri, 3 Apr 2026 22:13:42 +0000",
            "x-custom-header" => "custom-value",
            "mime-version" => "1.0",
            "content-type" => "multipart/mixed; boundary=\"original\""
          },
          bcc: ["hidden@resend.dev"],
          cc: ["cc@resend.dev"],
          reply_to: ["reply@resend.dev"],
          received_for: ["forwarded@example.com"],
          message_id: "<111-222-333@email.example.com>",
          raw: nil,
          attachments: [
            {
              "id" => "att_inline",
              "filename" => "avatar.png",
              "content_type" => "image/png",
              "content_disposition" => "inline",
              "content_id" => "img001",
              "size" => 4096
            },
            {
              "id" => "att_file",
              "filename" => "document.pdf",
              "content_type" => "application/pdf",
              "content_disposition" => nil,
              "content_id" => nil,
              "size" => 13_264
            }
          ]
        }
      end

      before do
        allow(Resend::Emails::Receiving).to receive(:get).and_return(email_payload)
        allow(Resend::Emails::Receiving::Attachments).to receive(:get)
          .with(email_id: email_id, id: "att_inline")
          .and_return({ id: "att_inline", download_url: "https://cdn.resend.com/att_inline" })
        allow(Resend::Emails::Receiving::Attachments).to receive(:get)
          .with(email_id: email_id, id: "att_file")
          .and_return({ id: "att_file", download_url: "https://cdn.resend.com/att_file" })
        allow(HTTParty).to receive(:get).with("https://cdn.resend.com/att_inline")
                                        .and_return(http_response(200, png_content))
        allow(HTTParty).to receive(:get).with("https://cdn.resend.com/att_file")
                                        .and_return(http_response(200, pdf_content))
      end

      let(:mail) { Mail.read_from_string(builder.raw_email) }

      it "preserves the envelope" do
        expect(mail.subject).to eq("Hello World")
        expect(mail.to).to eq(["delivered@resend.dev"])
        expect(mail.cc).to eq(["cc@resend.dev"])
        expect(mail.bcc).to eq(["hidden@resend.dev"])
        expect(mail.reply_to).to eq(["reply@resend.dev"])
        expect(mail.message_id).to eq("111-222-333@email.example.com")
      end

      it "prefers the original headers over the top-level fields" do
        expect(mail[:from].to_s).to eq("Acme <onboarding@resend.dev>")
        expect(mail.date.year).to eq(2026)
      end

      it "copies non-structural headers and skips structural ones" do
        expect(mail["x-custom-header"].to_s).to eq("custom-value")
        expect(mail.content_type).not_to include("original")
      end

      it "maps received_for addresses to X-Original-To" do
        expect(mail["X-Original-To"].to_s).to eq("forwarded@example.com")
      end

      it "builds text and html parts" do
        expect(mail).to be_multipart
        expect(mail.text_part.decoded).to eq("Hi")
        expect(mail.html_part.decoded).to include("cid:img001")
      end

      it "downloads and attaches the attachments" do
        expect(mail.attachments.map(&:filename)).to contain_exactly("avatar.png", "document.pdf")

        pdf = mail.attachments.detect { |a| a.filename == "document.pdf" }
        expect(pdf.decoded).to eq(pdf_content)
        expect(pdf.content_type).to start_with("application/pdf")
        expect(pdf.content_disposition).to start_with("attachment")
      end

      it "marks inline attachments with their content id" do
        png = mail.attachments.detect { |a| a.filename == "avatar.png" }
        expect(png.decoded).to eq(png_content)
        expect(png.content_id).to eq("<img001>")
        expect(png).to be_inline
      end

      it "raises when an attachment download fails" do
        allow(HTTParty).to receive(:get).with("https://cdn.resend.com/att_file")
                                        .and_return(http_response(500, "oops"))
        expect { builder.raw_email }.to raise_error(Resend::Error::ServerError, /HTTP 500/)
      end
    end

    context "when the email is text-only" do
      before do
        allow(Resend::Emails::Receiving).to receive(:get).and_return(
          {
            id: email_id,
            from: "onboarding@resend.dev",
            to: ["delivered@resend.dev"],
            subject: "Plain",
            created_at: "2026-04-03T22:13:42.674Z",
            text: "Just text",
            html: nil,
            headers: {},
            attachments: []
          }
        )
      end

      it "builds a simple text message" do
        mail = Mail.read_from_string(builder.raw_email)
        expect(mail).not_to be_multipart
        expect(mail.decoded).to eq("Just text")
        expect(mail.date).not_to be_nil
      end
    end

    context "when the email is html-only" do
      before do
        allow(Resend::Emails::Receiving).to receive(:get).and_return(
          {
            id: email_id,
            from: "onboarding@resend.dev",
            to: ["delivered@resend.dev"],
            subject: "Rich",
            html: "<strong>Hello</strong>",
            text: nil,
            headers: {},
            attachments: []
          }
        )
      end

      it "builds a message with only an html part" do
        mail = Mail.read_from_string(builder.raw_email)
        expect(mail.html_part.decoded).to eq("<strong>Hello</strong>")
        expect(mail.text_part).to be_nil
      end
    end
  end
end
