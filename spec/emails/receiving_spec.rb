# frozen_string_literal: true

RSpec.describe "Emails::Receiving" do
  before do
    Resend.api_key = "re_123"
  end

  describe "get" do
    it "should retrieve a received email" do
      resp = {
        "object" => "email",
        "id" => "4ef9a417-02e9-4d39-ad75-9611e0fcc33c",
        "to" => ["delivered@resend.dev"],
        "from" => "Acme <onboarding@resend.dev>",
        "created_at" => "2023-04-03T22:13:42.674981+00:00",
        "subject" => "Hello World",
        "html" => "Congrats on sending your <strong>first email</strong>!",
        "text" => nil,
        "bcc" => [],
        "cc" => [],
        "reply_to" => [],
        "message_id" => "<example+123>",
        "attachments" => [
          {
            "id" => "2a0c9ce0-3112-4728-976e-47ddcd16a318",
            "filename" => "avatar.png",
            "content_type" => "image/png",
            "content_disposition" => "inline",
            "content_id" => "img001"
          }
        ]
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      email = Resend::Emails::Receiving.get(resp["id"])
      expect(email[:subject]).to eql("Hello World")
      expect(email[:id]).to eql("4ef9a417-02e9-4d39-ad75-9611e0fcc33c")
      expect(email[:from]).to eql("Acme <onboarding@resend.dev>")
      expect(email[:to]).to eql(["delivered@resend.dev"])
      expect(email[:attachments].length).to eql(1)
    end

    it "should call the correct API endpoint" do
      resp = {
        "object" => "email",
        "id" => "4ef9a417-02e9-4d39-ad75-9611e0fcc33c"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Emails::Receiving.get("4ef9a417-02e9-4d39-ad75-9611e0fcc33c")

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/receiving/4ef9a417-02e9-4d39-ad75-9611e0fcc33c",
        hash_including(
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json",
            "Authorization" => "Bearer re_123",
            "User-Agent" => "resend-ruby:#{Resend::VERSION}"
          }
        )
      )
    end

    it "should raise an error when email is not found" do
      resp = {
        "statusCode" => 404,
        "name" => "not_found",
        "message" => "Email not found"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      expect { Resend::Emails::Receiving.get("invalid_id") }.to raise_error(
        Resend::Error::InvalidRequestError,
        /Email not found/
      )
    end
  end

  describe "list" do
    it "should list received emails without parameters" do
      resp = {
        "object" => "list",
        "has_more" => true,
        "data" => [
          {
            "id" => "a39999a6-88e3-48b1-888b-beaabcde1b33",
            "to" => ["recipient@example.com"],
            "from" => "sender@example.com",
            "created_at" => "2025-10-09 14:37:40.951732+00",
            "subject" => "Hello World",
            "bcc" => [],
            "cc" => [],
            "reply_to" => [],
            "message_id" => "<111-222-333@email.provider.example.com>",
            "attachments" => [
              {
                "filename" => "example.txt",
                "content_type" => "text/plain",
                "content_id" => nil,
                "content_disposition" => "attachment",
                "id" => "47e999c7-c89c-4999-bf32-aaaaa1c3ff21",
                "size" => 13
              }
            ]
          }
        ]
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      result = Resend::Emails::Receiving.list
      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to eql(true)
      expect(result[:data].length).to eql(1)
      expect(result[:data].first["subject"]).to eql("Hello World")
    end

    it "should list received emails with limit parameter" do
      resp = {
        "object": "list",
        "has_more": false,
        "data": []
      }

      request_instance = instance_double(Resend::Request)
      allow(request_instance).to receive(:perform).and_return(resp)
      allow(Resend::Request).to receive(:new) do |path, body, verb|
        expect(path).to include("limit=50")
        request_instance
      end

      result = Resend::Emails::Receiving.list(limit: 50)
      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to eql(false)
    end

    it "should list received emails with pagination parameters" do
      resp = {
        "object": "list",
        "has_more": true,
        "data": []
      }

      request_instance = instance_double(Resend::Request)
      allow(request_instance).to receive(:perform).and_return(resp)
      allow(Resend::Request).to receive(:new) do |path, body, verb|
        expect(path).to include("limit=20")
        expect(path).to include("after=cursor_123")
        expect(path).to include("before=cursor_456")
        request_instance
      end

      result = Resend::Emails::Receiving.list(limit: 20, after: "cursor_123", before: "cursor_456")
      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to eql(true)
    end

    it "should call the correct API endpoint for list" do
      resp = {
        "object" => "list",
        "has_more" => false,
        "data" => []
      }

      request_instance = instance_double(Resend::Request)
      allow(request_instance).to receive(:perform).and_return(resp)
      allow(Resend::Request).to receive(:new) do |path, body, verb|
        expect(path).to eq("emails/receiving")
        expect(verb).to eq("get")
        request_instance
      end

      Resend::Emails::Receiving.list
    end
  end
end
