# frozen_string_literal: true

RSpec.describe "Inboxes::Threads::Emails" do
  let(:inbox_id) { "b3e2b2b6-3f0e-4c8e-9ad3-2f43a1e2c7f1" }
  let(:thread_id) { "4d8e2a1c-9b3f-4c6d-8a21-3e5f7c9c0d12" }
  let(:email_id) { "5b1a9f47-2c8d-4e6f-9a03-1d2e3f4a5b60" }
  let(:sent_id) { "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794" }
  let(:email_path) { "inboxes/#{inbox_id}/threads/#{thread_id}/emails/#{email_id}" }
  let(:ids) { { inbox_id: inbox_id, thread_id: thread_id, email_id: email_id } }

  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  def expect_request(path, body, verb, resp)
    expect(Resend::Request).to receive(:new).with(path, body, verb).and_return(double("req", perform: resp))
  end

  def expect_post(path, body, resp, options = {})
    expect(Resend::Request).to receive(:new).with(path, body, "post", options: options)
                                            .and_return(double("req", perform: resp))
  end

  describe "list" do
    it "should list thread emails with pagination" do
      resp = { object: "list", has_more: true, data: [{ "id" => email_id, "direction" => "inbound" }] }
      expect_request("inboxes/#{inbox_id}/threads/#{thread_id}/emails?limit=1", {}, "get", resp)

      emails = Resend::Inboxes::Threads::Emails.list(inbox_id: inbox_id, thread_id: thread_id, limit: 1)
      expect(emails[:has_more]).to be true
      expect(emails[:data].first["direction"]).to eql("inbound")
    end

    it "should raise when thread_id is missing" do
      expect do
        Resend::Inboxes::Threads::Emails.list(inbox_id: inbox_id)
      end.to raise_error(ArgumentError, "thread_id is required")
    end
  end

  describe "get" do
    it "should retrieve a thread email" do
      resp = { object: "inbox_thread_email", id: email_id, direction: "inbound", attachments: [] }
      expect_request(email_path, {}, "get", resp)

      email = Resend::Inboxes::Threads::Emails.get(ids)
      expect(email[:id]).to eql(email_id)
    end

    it "should raise when email_id is missing" do
      expect do
        Resend::Inboxes::Threads::Emails.get(inbox_id: inbox_id, thread_id: thread_id)
      end.to raise_error(ArgumentError, "email_id is required")
    end
  end

  describe "reply" do
    it "should reply with attachments" do
      body = {
        text: "Refund issued for order 1041.",
        reply_all: true,
        cc: ["billing@acme.com"],
        attachments: [{ filename: "receipt.txt", content: "aGVsbG8=" }]
      }
      expect_post("#{email_path}/reply", body, { id: sent_id })

      reply = Resend::Inboxes::Threads::Emails.reply({ **ids, **body })
      expect(reply[:id]).to eql(sent_id)
    end

    it "should reply with custom headers" do
      body = { text: "Hi", headers: { "X-Ticket-Id" => "4821" } }
      expect_post("#{email_path}/reply", body, { id: sent_id })

      Resend::Inboxes::Threads::Emails.reply({ **ids, **body })
    end

    it "should raise when email_id is missing" do
      expect do
        Resend::Inboxes::Threads::Emails.reply({ inbox_id: inbox_id, thread_id: thread_id, text: "Hi" })
      end.to raise_error(ArgumentError, "email_id is required")
    end
  end

  describe "idempotency key" do
    it "should pass the idempotency key on reply" do
      expect_post("#{email_path}/reply", { text: "Hi" }, { id: sent_id }, { idempotency_key: "reply-1" })

      Resend::Inboxes::Threads::Emails.reply({ **ids, text: "Hi" }, options: { idempotency_key: "reply-1" })
    end

    it "should pass the idempotency key on forward" do
      expect_post("#{email_path}/forward", { to: "a@example.org" }, { id: sent_id }, { idempotency_key: "fwd-1" })

      Resend::Inboxes::Threads::Emails.forward({ **ids, to: "a@example.org" }, options: { idempotency_key: "fwd-1" })
    end
  end

  describe "forward" do
    it "should forward an email" do
      body = { to: ["colleague@example.org"], text: "Flagging this refund request for you.", subject: "Fwd: Refund" }
      expect_post("#{email_path}/forward", body, { id: sent_id })

      forward = Resend::Inboxes::Threads::Emails.forward({ **ids, **body })
      expect(forward[:id]).to eql(sent_id)
    end

    it "should raise when inbox_id is missing" do
      expect do
        Resend::Inboxes::Threads::Emails.forward({ thread_id: thread_id, email_id: email_id, to: "a@example.org" })
      end.to raise_error(ArgumentError, "inbox_id is required")
    end
  end
end
