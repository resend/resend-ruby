# frozen_string_literal: true

RSpec.describe "Webhooks" do

  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  describe "create" do
    it "should create webhook" do
      resp = {
        "object": "webhook",
        "id": "4dd369bc-aa82-4ff3-97de-514ae3000ee0",
        "signing_secret": "whsec_xxxxxxxxxx"
      }
      params = {
        "endpoint": "https://webhook.example.com/handler",
        "events": ["email.sent", "email.delivered", "email.bounced"]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      result = Resend::Webhooks.create(params)

      expect(result[:id]).to eql("4dd369bc-aa82-4ff3-97de-514ae3000ee0")
      expect(result[:object]).to eql("webhook")
      expect(result[:signing_secret]).to eql("whsec_xxxxxxxxxx")
    end

    it "should handle missing required parameters" do
      resp = {
        "statusCode" => 422,
        "message" => "Missing required parameter"
      }
      allow(resp).to receive(:code).and_return(422)
      allow(resp).to receive(:body).and_return(resp.to_json)
      allow(HTTParty).to receive(:send).and_return(resp)

      expect { Resend::Webhooks.create({}) }.to raise_error(Resend::Error::InvalidRequestError)
    end
  end

  describe "get" do
    it "should retrieve a webhook" do
      resp = {
        "object": "webhook",
        "id": "4dd369bc-aa82-4ff3-97de-514ae3000ee0",
        "created_at": "2023-08-22T15:28:00.000Z",
        "status": "enabled",
        "endpoint": "https://webhook.example.com/handler",
        "events": ["email.sent", "email.received"],
        "signing_secret": "whsec_xxxxxxxxxx"
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      webhook = Resend::Webhooks.get("4dd369bc-aa82-4ff3-97de-514ae3000ee0")

      expect(webhook[:id]).to eql("4dd369bc-aa82-4ff3-97de-514ae3000ee0")
      expect(webhook[:object]).to eql("webhook")
      expect(webhook[:status]).to eql("enabled")
      expect(webhook[:endpoint]).to eql("https://webhook.example.com/handler")
      expect(webhook[:events]).to eql(["email.sent", "email.received"])
      expect(webhook[:signing_secret]).to eql("whsec_xxxxxxxxxx")
      expect(webhook[:created_at]).to eql("2023-08-22T15:28:00.000Z")
    end

    it "should handle webhook not found" do
      resp = {
        "statusCode" => 404,
        "message" => "Webhook not found"
      }
      allow(resp).to receive(:code).and_return(404)
      allow(resp).to receive(:body).and_return(resp.to_json)
      allow(HTTParty).to receive(:send).and_return(resp)

      expect { Resend::Webhooks.get("invalid-id") }.to raise_error(Resend::Error::InvalidRequestError)
    end
  end

  describe "update" do
    it "should update webhook" do
      resp = {
        "object": "webhook",
        "id": "430eed87-632a-4ea6-90db-0aace67ec228"
      }
      params = {
        "webhook_id": "430eed87-632a-4ea6-90db-0aace67ec228",
        "endpoint": "https://new-webhook.example.com/handler",
        "events": ["email.sent", "email.delivered"],
        "status": "enabled"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      result = Resend::Webhooks.update(params)

      expect(result[:id]).to eql("430eed87-632a-4ea6-90db-0aace67ec228")
      expect(result[:object]).to eql("webhook")
    end

    it "should update webhook status only" do
      resp = {
        "object": "webhook",
        "id": "430eed87-632a-4ea6-90db-0aace67ec228"
      }
      params = {
        "webhook_id": "430eed87-632a-4ea6-90db-0aace67ec228",
        "status": "disabled"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      result = Resend::Webhooks.update(params)

      expect(result[:id]).to eql("430eed87-632a-4ea6-90db-0aace67ec228")
    end
  end

  describe "list" do
    it "should list webhooks" do
      resp = {
        "object": "list",
        "has_more": false,
        "data": [
          {
            "id": "7ab123cd-ef45-6789-abcd-ef0123456789",
            "created_at": "2023-09-10T10:15:30.000Z",
            "status": "disabled",
            "endpoint": "https://first-webhook.example.com/handler",
            "events": ["email.delivered", "email.bounced"]
          },
          {
            "id": "4dd369bc-aa82-4ff3-97de-514ae3000ee0",
            "created_at": "2023-08-22T15:28:00.000Z",
            "status": "enabled",
            "endpoint": "https://second-webhook.example.com/receive",
            "events": ["email.received"]
          }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      webhooks = Resend::Webhooks.list

      expect(webhooks[:object]).to eql("list")
      expect(webhooks[:has_more]).to eql(false)
      expect(webhooks[:data].length).to eql(2)

      expect(webhooks[:data][0][:id]).to eql("7ab123cd-ef45-6789-abcd-ef0123456789")
      expect(webhooks[:data][0][:status]).to eql("disabled")
      expect(webhooks[:data][0][:endpoint]).to eql("https://first-webhook.example.com/handler")
      expect(webhooks[:data][0][:events]).to eql(["email.delivered", "email.bounced"])
      expect(webhooks[:data][0][:created_at]).to eql("2023-09-10T10:15:30.000Z")

      expect(webhooks[:data][1][:id]).to eql("4dd369bc-aa82-4ff3-97de-514ae3000ee0")
      expect(webhooks[:data][1][:status]).to eql("enabled")
      expect(webhooks[:data][1][:endpoint]).to eql("https://second-webhook.example.com/receive")
      expect(webhooks[:data][1][:events]).to eql(["email.received"])
      expect(webhooks[:data][1][:created_at]).to eql("2023-08-22T15:28:00.000Z")
    end

    it "should list webhooks with pagination" do
      resp = {
        "object": "list",
        "has_more": true,
        "data": [
          {
            "id": "7ab123cd-ef45-6789-abcd-ef0123456789",
            "created_at": "2023-09-10T10:15:30.000Z",
            "status": "enabled",
            "endpoint": "https://webhook.example.com/handler",
            "events": ["email.sent"]
          }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      webhooks = Resend::Webhooks.list(limit: 1, after: "4dd369bc-aa82-4ff3-97de-514ae3000ee0")

      expect(webhooks[:object]).to eql("list")
      expect(webhooks[:has_more]).to eql(true)
      expect(webhooks[:data].length).to eql(1)
    end

    it "should handle empty list" do
      resp = {
        "object": "list",
        "has_more": false,
        "data": []
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      webhooks = Resend::Webhooks.list

      expect(webhooks[:object]).to eql("list")
      expect(webhooks[:has_more]).to eql(false)
      expect(webhooks[:data].length).to eql(0)
    end
  end

  describe "remove" do
    it "should remove webhook" do
      resp = {
        "object": "webhook",
        "id": "4dd369bc-aa82-4ff3-97de-514ae3000ee0",
        "deleted": true
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      result = Resend::Webhooks.remove("4dd369bc-aa82-4ff3-97de-514ae3000ee0")

      expect(result[:id]).to eql("4dd369bc-aa82-4ff3-97de-514ae3000ee0")
      expect(result[:deleted]).to eql(true)
    end

    it "should handle webhook not found on delete" do
      resp = {
        "statusCode" => 404,
        "message" => "Webhook not found"
      }
      allow(resp).to receive(:code).and_return(404)
      allow(resp).to receive(:body).and_return(resp.to_json)
      allow(HTTParty).to receive(:send).and_return(resp)

      expect { Resend::Webhooks.remove("invalid-id") }.to raise_error(Resend::Error::InvalidRequestError)
    end
  end

end
