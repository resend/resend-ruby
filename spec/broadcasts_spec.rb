# frozen_string_literal: true

RSpec.describe "Broadcasts" do

  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  describe "create" do
    it "should create broadcast with audience_id" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      params = {
        "audience_id": "123123"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(Resend::Broadcasts.create(params)[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
    end

    it "should create broadcast with segment_id" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      params = {
        "segment_id": "123123"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(Resend::Broadcasts.create(params)[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
    end

    it "should create broadcast with both segment_id and audience_id (segment_id takes precedence)" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      params = {
        "segment_id": "segment123",
        "audience_id": "audience123"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(Resend::Broadcasts.create(params)[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
    end

    it "should create and send broadcast with send: true" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      params = {
        segment_id: "123123",
        from: "onboarding@resend.dev",
        subject: "Hello World",
        html: "<p>Hello</p>",
        send: true
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(Resend::Broadcasts.create(params)[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
    end

    it "should create and schedule broadcast with send: true and scheduled_at" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      params = {
        segment_id: "123123",
        from: "onboarding@resend.dev",
        subject: "Hello World",
        html: "<p>Hello</p>",
        send: true,
        scheduled_at: "in 1 min"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(Resend::Broadcasts.create(params)[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
    end
  end

  describe "update" do
    it "should update broadcast" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      params = {
        "broadcast_id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(Resend::Broadcasts.update(params)[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
    end
  end

  describe "send" do
    it "should send broadcast" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      params = {
        "broadcast_id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794",
        "scheduled_at": "in 1 min"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(Resend::Broadcasts.send(params)[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
    end
  end

  describe "list" do
    it "should list broadcasts" do
      resp = {
        "object": "list",
        "data": [
          {
            "id" => "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794",
            "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
            "status" => "draft",
            "created_at" => "2024-11-01 15:13:31.723+00",
            "scheduled_at" => nil,
            "sent_at" => nil
          },
          {
            "id" => "559ac32e-9ef5-46fb-82a1-b76b840c0f7b",
            "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
            "status" => "sent",
            "created_at" => "2024-12-01 19:32:22.98+00",
            "scheduled_at" => "2024-12-02 19:32:22.98+00",
            "sent_at" => "2024-12-02 19:32:22.98+00"
          }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      broadcasts = Resend::Broadcasts.list[:data]

      expect(broadcasts.length).to eql(2)

      expect(broadcasts[0]["id"]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
      expect(broadcasts[0]["audience_id"]).to eql("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      expect(broadcasts[0]["status"]).to eql("draft")
      expect(broadcasts[0]["created_at"]).to eql("2024-11-01 15:13:31.723+00")
      expect(broadcasts[0]["scheduled_at"]).to eql(nil)
      expect(broadcasts[0]["sent_at"]).to eql(nil)

      expect(broadcasts[1]["id"]).to eql("559ac32e-9ef5-46fb-82a1-b76b840c0f7b")
      expect(broadcasts[1]["audience_id"]).to eql("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      expect(broadcasts[1]["status"]).to eql("sent")
      expect(broadcasts[1]["created_at"]).to eql("2024-12-01 19:32:22.98+00")
      expect(broadcasts[1]["scheduled_at"]).to eql("2024-12-02 19:32:22.98+00")
      expect(broadcasts[1]["sent_at"]).to eql("2024-12-02 19:32:22.98+00")
    end
  end

  describe "clicked_links" do
    it "lists a broadcast's clicked links" do
      resp = {
        "object": "list",
        "has_more": false,
        "data": [
          {
            "id" => "b2Zmc2V0OjA",
            "url" => "https://resend.com/pricing",
            "clicks" => 42,
            "unique_clicks" => 30
          },
          {
            "id" => "b2Zmc2V0OjE",
            "url" => "https://resend.com/docs",
            "clicks" => 17,
            "unique_clicks" => 15
          }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      result = Resend::Broadcasts.clicked_links("559ac32e-9ef5-46fb-82a1-b76b840c0f7b")

      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to eql(false)
      expect(result[:data].length).to eql(2)
      expect(result[:data][0]["url"]).to eql("https://resend.com/pricing")
      expect(result[:data][0]["clicks"]).to eql(42)
      expect(result[:data][0]["unique_clicks"]).to eql(30)
    end

    it "accepts pagination parameters" do
      resp = {
        "object": "list",
        "has_more": false,
        "data": []
      }

      request_instance = instance_double(Resend::Request)
      allow(request_instance).to receive(:perform).and_return(resp)
      allow(Resend::Request).to receive(:new) do |path, _body, _verb|
        expect(path).to include("broadcasts/559ac32e-9ef5-46fb-82a1-b76b840c0f7b/clicked-links")
        expect(path).to include("limit=10")
        expect(path).to include("after=key_123")
        expect(path).to include("before=key_456")
        request_instance
      end

      params = { limit: 10, after: "key_123", before: "key_456" }
      result = Resend::Broadcasts.clicked_links("559ac32e-9ef5-46fb-82a1-b76b840c0f7b", params)
      expect(result[:object]).to eql("list")
    end
  end

  describe "cancel" do
    it "should cancel broadcast" do
      resp = {
        "object": "broadcast",
        "id": "559ac32e-9ef5-46fb-82a1-b76b840c0f7b"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      broadcast = Resend::Broadcasts.cancel(resp[:id])
      expect(broadcast[:id]).to eql "559ac32e-9ef5-46fb-82a1-b76b840c0f7b"
    end
  end

  describe "remove" do
    it "should remove broadcast" do
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return("")
      expect { Resend::Broadcasts.remove }.not_to raise_error
    end
  end

  describe "recipients" do
    it "should raise when type is missing" do
      expect do
        Resend::Broadcasts.recipients("559ac32e-9ef5-46fb-82a1-b76b840c0f7b", {})
      end.to raise_error(ArgumentError, "type is required")
    end

    it "should list recipients for a basic event type" do
      resp = {
        "object": "list",
        "has_more": false,
        "data": [
          {
            "id" => "b2Zmc2V0OjA",
            "contact_id" => "e169aa45-1ecf-4183-9955-b1499d5701d3",
            "email" => "carter@example.com"
          }
        ]
      }
      expect(Resend::Request).to receive(:new).with(
        "broadcasts/559ac32e-9ef5-46fb-82a1-b76b840c0f7b/recipients?type=sent",
        {},
        "get"
      ).and_call_original
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      recipients = Resend::Broadcasts.recipients(
        "559ac32e-9ef5-46fb-82a1-b76b840c0f7b",
        { type: "sent" }
      )

      expect(recipients[:object]).to eql("list")
      expect(recipients[:has_more]).to eql(false)
      expect(recipients[:data].length).to eql(1)
      expect(recipients[:data][0]["id"]).to eql("b2Zmc2V0OjA")
      expect(recipients[:data][0]["contact_id"]).to eql("e169aa45-1ecf-4183-9955-b1499d5701d3")
      expect(recipients[:data][0]["email"]).to eql("carter@example.com")
    end

    it "should list recipients with count for opened type" do
      resp = {
        "object": "list",
        "has_more": false,
        "data": [
          {
            "id" => "b2Zmc2V0OjA",
            "contact_id" => "e169aa45-1ecf-4183-9955-b1499d5701d3",
            "email" => "carter@example.com",
            "count" => 3
          }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      recipients = Resend::Broadcasts.recipients(
        "559ac32e-9ef5-46fb-82a1-b76b840c0f7b",
        { type: "opened" }
      )

      expect(recipients[:data][0]["count"]).to eql(3)
    end

    it "should list recipients with clicked_links for clicked type" do
      resp = {
        "object": "list",
        "has_more": false,
        "data": [
          {
            "id" => "b2Zmc2V0OjA",
            "contact_id" => "e169aa45-1ecf-4183-9955-b1499d5701d3",
            "email" => "carter@example.com",
            "count" => 2,
            "clicked_links" => [
              { "url" => "https://resend.com/pricing", "clicks" => 2 }
            ]
          }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      recipients = Resend::Broadcasts.recipients(
        "559ac32e-9ef5-46fb-82a1-b76b840c0f7b",
        { type: "clicked" }
      )

      expect(recipients[:data][0]["count"]).to eql(2)
      expect(recipients[:data][0]["clicked_links"]).to eql(
        [{ "url" => "https://resend.com/pricing", "clicks" => 2 }]
      )
    end

    it "should list recipients with bounce_type for bounced type" do
      resp = {
        "object": "list",
        "has_more": false,
        "data": [
          {
            "id" => "b2Zmc2V0OjA",
            "contact_id" => nil,
            "email" => "carter@example.com",
            "bounce_type" => "permanent"
          }
        ]
      }
      expect(Resend::Request).to receive(:new).with(
        "broadcasts/559ac32e-9ef5-46fb-82a1-b76b840c0f7b/recipients?type=bounced&bounce_type=permanent",
        {},
        "get"
      ).and_call_original
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      recipients = Resend::Broadcasts.recipients(
        "559ac32e-9ef5-46fb-82a1-b76b840c0f7b",
        { type: "bounced", bounce_type: "permanent" }
      )

      expect(recipients[:data][0]["contact_id"]).to eql(nil)
      expect(recipients[:data][0]["bounce_type"]).to eql("permanent")
    end

    it "should raise when broadcast is not found" do
      resp = {
        "statusCode" => 404,
        "name" => "not_found",
        "message" => "Broadcast not found"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      expect do
        Resend::Broadcasts.recipients("missing-id", { type: "sent" })
      end.to raise_error(Resend::Error::NotFoundError, /Broadcast not found/)
    end
  end

  describe "get broadcast" do

    it "should retrieve a broadcast" do

      resp = {
        "object": "broadcast",
        "id": "559ac32e-9ef5-46fb-82a1-b76b840c0f7b",
        "name": "Announcements",
        "audience_id": "78261eea-8f8b-4381-83c6-79fa7120f1cf",
        "from": "Acme <onboarding@resend.dev>",
        "subject": "hello world",
        "reply_to": nil,
        "preview_text": "Check out our latest announcements",
        "status": "draft",
        "created_at": "2024-12-01 19:32:22.98+00",
        "scheduled_at": nil,
        "sent_at": nil,
        "html": "<p>hello world</p>",
        "text": "hello world"
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      broadcast = Resend::Broadcasts.get("559ac32e-9ef5-46fb-82a1-b76b840c0f7b")

      expect(broadcast[:object]).to eql "broadcast"
      expect(broadcast[:id]).to eql "559ac32e-9ef5-46fb-82a1-b76b840c0f7b"
      expect(broadcast[:name]).to eql "Announcements"
      expect(broadcast[:audience_id]).to eql "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      expect(broadcast[:from]).to eql "Acme <onboarding@resend.dev>"
      expect(broadcast[:subject]).to eql "hello world"
      expect(broadcast[:reply_to]).to eql nil
      expect(broadcast[:preview_text]).to eql "Check out our latest announcements"
      expect(broadcast[:status]).to eql "draft"
      expect(broadcast[:created_at]).to eql "2024-12-01 19:32:22.98+00"
      expect(broadcast[:scheduled_at]).to eql nil
      expect(broadcast[:sent_at]).to eql nil
      expect(broadcast[:html]).to eql "<p>hello world</p>"
      expect(broadcast[:text]).to eql "hello world"
    end
  end

end
