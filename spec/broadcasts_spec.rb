# frozen_string_literal: true

RSpec.describe "Broadcasts" do

  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  describe "create" do
    it "should create broadcast" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      params = {
        "audience_id": "123123"
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
            "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794",
            "audience_id": "78261eea-8f8b-4381-83c6-79fa7120f1cf",
            "status": "draft",
            "created_at": "2024-11-01T15:13:31.723Z",
            "scheduled_at": nil,
            "sent_at": nil
          },
          {
            "id": "559ac32e-9ef5-46fb-82a1-b76b840c0f7b",
            "audience_id": "78261eea-8f8b-4381-83c6-79fa7120f1cf",
            "status": "sent",
            "created_at": "2024-12-01T19:32:22.980Z",
            "scheduled_at": "2024-12-02T19:32:22.980Z",
            "sent_at": "2024-12-02T19:32:22.980Z"
          }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      broadcasts = Resend::Broadcasts.list[:data]

      expect(broadcasts.length).to eql(2)

      expect(broadcasts[0][:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
      expect(broadcasts[0][:audience_id]).to eql("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      expect(broadcasts[0][:status]).to eql("draft")
      expect(broadcasts[0][:created_at]).to eql("2024-11-01T15:13:31.723Z")
      expect(broadcasts[0][:scheduled_at]).to eql(nil)
      expect(broadcasts[0][:sent_at]).to eql(nil)

      expect(broadcasts[1][:id]).to eql("559ac32e-9ef5-46fb-82a1-b76b840c0f7b")
      expect(broadcasts[1][:audience_id]).to eql("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      expect(broadcasts[1][:status]).to eql("sent")
      expect(broadcasts[1][:created_at]).to eql("2024-12-01T19:32:22.980Z")
      expect(broadcasts[1][:scheduled_at]).to eql("2024-12-02T19:32:22.980Z")
      expect(broadcasts[1][:sent_at]).to eql("2024-12-02T19:32:22.980Z")
    end
  end

  describe "remove" do
    it "should remove broadcast" do
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return("")
      expect { Resend::Broadcasts.remove }.not_to raise_error
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
        "created_at": "2024-12-01T19:32:22.980Z",
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
      expect(broadcast[:created_at]).to eql "2024-12-01T19:32:22.980Z"
      expect(broadcast[:scheduled_at]).to eql nil
      expect(broadcast[:sent_at]).to eql nil
      expect(broadcast[:html]).to eql "<p>hello world</p>"
      expect(broadcast[:text]).to eql "hello world"
    end
  end

end
