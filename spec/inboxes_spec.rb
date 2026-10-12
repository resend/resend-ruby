# frozen_string_literal: true

RSpec.describe "Inboxes" do
  let(:inbox_id) { "b3e2b2b6-3f0e-4c8e-9ad3-2f43a1e2c7f1" }

  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  def expect_request(path, body, verb, resp)
    expect(Resend::Request).to receive(:new).with(path, body, verb).and_return(double("req", perform: resp))
  end

  describe "create" do
    it "should create an inbox" do
      params = { email_address: "support@acme.com", name: "Customer Support", from_name: "Ada", forwarding: true }
      expect_request("inboxes", params, "post", { object: "inbox", id: inbox_id })

      inbox = Resend::Inboxes.create(params)
      expect(inbox[:object]).to eql("inbox")
      expect(inbox[:id]).to eql(inbox_id)
    end
  end

  describe "list" do
    it "should list inboxes" do
      resp = {
        object: "list",
        has_more: false,
        data: [
          {
            "id" => inbox_id,
            "name" => "Customer Support",
            "email_address" => "support@acme.com",
            "from_name" => nil,
            "unread" => 3,
            "last_received" => nil
          }
        ]
      }
      expect_request("inboxes", {}, "get", resp)

      inboxes = Resend::Inboxes.list
      expect(inboxes[:has_more]).to be false
      expect(inboxes[:data].first["email_address"]).to eql("support@acme.com")
    end

    it "should pass pagination parameters" do
      expect_request("inboxes?limit=10&after=#{inbox_id}", {}, "get", { object: "list", data: [] })

      Resend::Inboxes.list(limit: 10, after: inbox_id)
    end
  end

  describe "get" do
    it "should retrieve an inbox by id" do
      resp = { object: "inbox", id: inbox_id, email_address: "support@acme.com", unread: 0, drafts: 1 }
      expect_request("inboxes/#{inbox_id}", {}, "get", resp)

      inbox = Resend::Inboxes.get(inbox_id)
      expect(inbox[:drafts]).to eql(1)
    end

    it "should encode an email address" do
      expect_request("inboxes/support%2Bteam%40acme.com", {}, "get", { object: "inbox", id: inbox_id })

      Resend::Inboxes.get("support+team@acme.com")
    end
  end

  describe "update" do
    it "should update an inbox" do
      expect_request("inboxes/#{inbox_id}", { name: "Support", from_name: "" }, "patch",
                     { object: "inbox", id: inbox_id })

      inbox = Resend::Inboxes.update(inbox_id: inbox_id, name: "Support", from_name: "")
      expect(inbox[:id]).to eql(inbox_id)
    end

    it "should raise when inbox_id is missing" do
      expect { Resend::Inboxes.update(name: "Support") }.to raise_error(ArgumentError, "inbox_id is required")
    end
  end

  describe "remove" do
    it "should remove an inbox" do
      expect_request("inboxes/#{inbox_id}", {}, "delete", { object: "inbox", id: inbox_id, deleted: true })

      inbox = Resend::Inboxes.remove(inbox_id)
      expect(inbox[:deleted]).to be true
    end
  end
end
