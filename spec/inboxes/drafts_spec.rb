# frozen_string_literal: true

RSpec.describe "Inboxes::Drafts" do
  let(:inbox_id) { "b3e2b2b6-3f0e-4c8e-9ad3-2f43a1e2c7f1" }
  let(:draft_id) { "9c4b1f2e-6d3a-4e8b-a1c7-0f5d2e9b3a48" }
  let(:thread_id) { "4d8e2a1c-9b3f-4c6d-8a21-3e5f7c9c0d12" }
  let(:email_id) { "5b1a9f47-2c8d-4e6f-9a03-1d2e3f4a5b60" }
  let(:sent_id) { "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794" }
  let(:draft_path) { "inboxes/#{inbox_id}/drafts/#{draft_id}" }

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
    it "should list drafts with pagination" do
      resp = { object: "list", has_more: false, data: [{ "id" => draft_id, "type" => "standalone", "snippet" => "Hi" }] }
      expect_request("inboxes/#{inbox_id}/drafts?limit=10&before=#{draft_id}", {}, "get", resp)

      drafts = Resend::Inboxes::Drafts.list(inbox_id: inbox_id, limit: 10, before: draft_id)
      expect(drafts[:data].first["type"]).to eql("standalone")
    end

    it "should raise when inbox_id is missing" do
      expect { Resend::Inboxes::Drafts.list({}) }.to raise_error(ArgumentError, "inbox_id is required")
    end
  end

  describe "create" do
    it "should create a draft with attachments" do
      attachments = [{ filename: "notes.txt", content: "aGVsbG8=", content_type: "text/plain" }]
      body = { to: ["delivered@resend.dev"], attachments: attachments }
      expect_post("inboxes/#{inbox_id}/drafts", body, { object: "inbox_draft", id: draft_id })

      draft = Resend::Inboxes::Drafts.create({ inbox_id: inbox_id, **body })
      expect(draft[:id]).to eql(draft_id)
    end

    it "should create a draft with a path attachment" do
      attachments = [{ filename: "invoice.pdf", path: "https://example.com/invoice.pdf" }]
      body = { to: ["delivered@resend.dev"], attachments: attachments }
      expect_post("inboxes/#{inbox_id}/drafts", body, { object: "inbox_draft", id: draft_id })

      draft = Resend::Inboxes::Drafts.create({ inbox_id: inbox_id, **body })
      expect(draft[:id]).to eql(draft_id)
    end

    it "should pass the idempotency key" do
      expect_post("inboxes/#{inbox_id}/drafts", { subject: "Hi" }, { object: "inbox_draft", id: draft_id },
                  { idempotency_key: "draft-1" })

      Resend::Inboxes::Drafts.create({ inbox_id: inbox_id, subject: "Hi" }, options: { idempotency_key: "draft-1" })
    end

    it "should create a reply draft" do
      body = { text: "Refund issued.", thread_id: thread_id, reply_to_email_id: email_id }
      expect_post("inboxes/#{inbox_id}/drafts", body, { object: "inbox_draft", id: draft_id })

      draft = Resend::Inboxes::Drafts.create({ inbox_id: inbox_id, **body })
      expect(draft[:id]).to eql(draft_id)
    end

    it "should raise when inbox_id is missing" do
      expect { Resend::Inboxes::Drafts.create({ text: "Hi" }) }.to raise_error(ArgumentError, "inbox_id is required")
    end
  end

  describe "get" do
    it "should retrieve a draft" do
      attachment = { "id" => "0b7d4e1a-5c2f-4d8e-9a3b-6f1e2d4c8a90", "filename" => "notes.txt",
                     "content_type" => "text/plain", "size" => 5 }
      resp = { object: "inbox_draft", id: draft_id, type: "standalone", to: ["ada@example.org"], email_id: nil,
               attachments: [attachment] }
      expect_request(draft_path, {}, "get", resp)

      draft = Resend::Inboxes::Drafts.get(inbox_id: inbox_id, draft_id: draft_id)
      expect(draft[:to]).to eql(["ada@example.org"])
      expect(draft[:attachments].first["size"]).to eql(5)
    end

    it "should raise when draft_id is missing" do
      expect { Resend::Inboxes::Drafts.get(inbox_id: inbox_id) }.to raise_error(ArgumentError, "draft_id is required")
    end
  end

  describe "update" do
    it "should update a draft and keep explicit nils" do
      body = { subject: "Refund issued for order 1041", cc: nil }
      resp = { object: "inbox_draft", id: draft_id, subject: "Refund issued for order 1041", cc: [] }
      expect_request(draft_path, body, "patch", resp)

      draft = Resend::Inboxes::Drafts.update(inbox_id: inbox_id, draft_id: draft_id, **body)
      expect(draft[:subject]).to eql("Refund issued for order 1041")
    end
  end

  describe "update attachments" do
    it "should send a path attachment" do
      attachments = [{ filename: "invoice.pdf", path: "https://example.com/invoice.pdf",
                       content_type: "application/pdf" }]
      expect_request(draft_path, { attachments: attachments }, "patch", { object: "inbox_draft", id: draft_id })

      draft = Resend::Inboxes::Drafts.update(inbox_id: inbox_id, draft_id: draft_id, attachments: attachments)
      expect(draft[:id]).to eql(draft_id)
    end

    it "should send an empty attachments array to remove them all" do
      expect_request(draft_path, { attachments: [] }, "patch", { object: "inbox_draft", id: draft_id, attachments: [] })

      draft = Resend::Inboxes::Drafts.update(inbox_id: inbox_id, draft_id: draft_id, attachments: [])
      expect(draft[:attachments]).to eql([])
    end
  end

  describe "remove" do
    it "should remove a draft" do
      expect_request(draft_path, {}, "delete", { object: "inbox_draft", id: draft_id, deleted: true })

      draft = Resend::Inboxes::Drafts.remove(inbox_id: inbox_id, draft_id: draft_id)
      expect(draft[:deleted]).to be true
    end
  end

  describe "send" do
    it "should send a draft with no body" do
      expect_post("#{draft_path}/send", {}, { id: sent_id })

      sent = Resend::Inboxes::Drafts.send({ inbox_id: inbox_id, draft_id: draft_id })
      expect(sent[:id]).to eql(sent_id)
    end

    it "should send custom headers in the body" do
      headers = { "X-Ticket-Id" => "4821" }
      expect_post("#{draft_path}/send", { headers: headers }, { id: sent_id })

      Resend::Inboxes::Drafts.send({ inbox_id: inbox_id, draft_id: draft_id, headers: headers })
    end

    it "should send the Idempotency-Key header" do
      resp = { "id" => sent_id }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Inboxes::Drafts.send({ inbox_id: inbox_id, draft_id: draft_id }, options: { idempotency_key: "send-1" })

      expect(HTTParty).to have_received(:send).with(
        :post,
        "#{Resend::Request::BASE_URL}#{draft_path}/send",
        {
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json",
            "Authorization" => "Bearer re_123",
            "User-Agent" => "resend-ruby:#{Resend::VERSION}",
            "Idempotency-Key" => "send-1"
          }
        }
      )
    end

    it "should raise when draft_id is missing" do
      expect { Resend::Inboxes::Drafts.send({ inbox_id: inbox_id }) }.to raise_error(ArgumentError, "draft_id is required")
    end
  end
end
