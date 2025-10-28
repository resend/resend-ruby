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

  describe "verify" do
    let(:webhook_secret) { "whsec_MfKQ9r8GKYqrTwjUPD8ILPZIo2LaLaSw" }
    let(:payload) { '{"type":"email.sent","created_at":"2024-01-01T00:00:00.000Z"}' }
    let(:msg_id) { "msg_2Lh9KX9FZ5Z5Z5Z5Z5Z5Z5Z5Z" }
    let(:timestamp) { Time.now.to_i.to_s }

    # Helper to generate valid signature
    def generate_test_signature(secret, msg_id, timestamp, payload)
      require "openssl"
      require "base64"

      # Strip whsec_ prefix and decode
      secret_bytes = Base64.strict_decode64(secret.sub(/^whsec_/, ""))

      # Create signed content
      signed_content = "#{msg_id}.#{timestamp}.#{payload}"

      # Generate HMAC-SHA256 signature
      hmac = OpenSSL::HMAC.digest(OpenSSL::Digest.new("sha256"), secret_bytes, signed_content)
      signature = Base64.strict_encode64(hmac)

      "v1,#{signature}"
    end

    it "should verify valid webhook signature" do
      signature = generate_test_signature(webhook_secret, msg_id, timestamp, payload)

      result = Resend::Webhooks.verify(
        payload: payload,
        headers: {
          svix_id: msg_id,
          svix_timestamp: timestamp,
          svix_signature: signature
        },
        webhook_secret: webhook_secret
      )

      expect(result).to be true
    end

    it "should verify with multiple signatures" do
      signature1 = generate_test_signature(webhook_secret, msg_id, timestamp, payload)
      signature2 = "v1,invalid_signature_here"

      result = Resend::Webhooks.verify(
        payload: payload,
        headers: {
          svix_id: msg_id,
          svix_timestamp: timestamp,
          svix_signature: "#{signature2} #{signature1}"
        },
        webhook_secret: webhook_secret
      )

      expect(result).to be true
    end

    it "should reject invalid signature" do
      expect {
        Resend::Webhooks.verify(
          payload: payload,
          headers: {
            svix_id: msg_id,
            svix_timestamp: timestamp,
            svix_signature: "v1,invalid_signature"
          },
          webhook_secret: webhook_secret
        )
      }.to raise_error("No matching signature found")
    end

    it "should reject tampered payload" do
      signature = generate_test_signature(webhook_secret, msg_id, timestamp, payload)
      tampered_payload = '{"type":"email.delivered","created_at":"2024-01-01T00:00:00.000Z"}'

      expect {
        Resend::Webhooks.verify(
          payload: tampered_payload,
          headers: {
            svix_id: msg_id,
            svix_timestamp: timestamp,
            svix_signature: signature
          },
          webhook_secret: webhook_secret
        )
      }.to raise_error("No matching signature found")
    end

    it "should reject expired timestamp" do
      old_timestamp = (Time.now.to_i - 400).to_s  # 400 seconds ago (beyond 5 min tolerance)
      signature = generate_test_signature(webhook_secret, msg_id, old_timestamp, payload)

      expect {
        Resend::Webhooks.verify(
          payload: payload,
          headers: {
            svix_id: msg_id,
            svix_timestamp: old_timestamp,
            svix_signature: signature
          },
          webhook_secret: webhook_secret
        )
      }.to raise_error(/Timestamp outside tolerance window/)
    end

    it "should reject future timestamp beyond tolerance" do
      future_timestamp = (Time.now.to_i + 400).to_s  # 400 seconds in the future
      signature = generate_test_signature(webhook_secret, msg_id, future_timestamp, payload)

      expect {
        Resend::Webhooks.verify(
          payload: payload,
          headers: {
            svix_id: msg_id,
            svix_timestamp: future_timestamp,
            svix_signature: signature
          },
          webhook_secret: webhook_secret
        )
      }.to raise_error(/Timestamp outside tolerance window/)
    end

    it "should accept timestamp within tolerance" do
      old_timestamp = (Time.now.to_i - 100).to_s  # 100 seconds ago (within 5 min tolerance)
      signature = generate_test_signature(webhook_secret, msg_id, old_timestamp, payload)

      result = Resend::Webhooks.verify(
        payload: payload,
        headers: {
          svix_id: msg_id,
          svix_timestamp: old_timestamp,
          svix_signature: signature
        },
        webhook_secret: webhook_secret
      )

      expect(result).to be true
    end

    it "should raise error when payload is missing" do
      expect {
        Resend::Webhooks.verify(
          payload: nil,
          headers: {
            svix_id: msg_id,
            svix_timestamp: timestamp,
            svix_signature: "v1,sig"
          },
          webhook_secret: webhook_secret
        )
      }.to raise_error("payload cannot be empty")
    end

    it "should raise error when webhook_secret is missing" do
      expect {
        Resend::Webhooks.verify(
          payload: payload,
          headers: {
            svix_id: msg_id,
            svix_timestamp: timestamp,
            svix_signature: "v1,sig"
          },
          webhook_secret: nil
        )
      }.to raise_error("webhook_secret cannot be empty")
    end

    it "should raise error when svix-id header is missing" do
      expect {
        Resend::Webhooks.verify(
          payload: payload,
          headers: {
            svix_id: nil,
            svix_timestamp: timestamp,
            svix_signature: "v1,sig"
          },
          webhook_secret: webhook_secret
        )
      }.to raise_error("svix-id header is required")
    end

    it "should raise error when svix-timestamp header is missing" do
      expect {
        Resend::Webhooks.verify(
          payload: payload,
          headers: {
            svix_id: msg_id,
            svix_timestamp: nil,
            svix_signature: "v1,sig"
          },
          webhook_secret: webhook_secret
        )
      }.to raise_error("svix-timestamp header is required")
    end

    it "should raise error when svix-signature header is missing" do
      expect {
        Resend::Webhooks.verify(
          payload: payload,
          headers: {
            svix_id: msg_id,
            svix_timestamp: timestamp,
            svix_signature: nil
          },
          webhook_secret: webhook_secret
        )
      }.to raise_error("svix-signature header is required")
    end

    it "should handle webhook secret without whsec_ prefix" do
      secret_without_prefix = webhook_secret.sub(/^whsec_/, "")
      signature = generate_test_signature(webhook_secret, msg_id, timestamp, payload)

      result = Resend::Webhooks.verify(
        payload: payload,
        headers: {
          svix_id: msg_id,
          svix_timestamp: timestamp,
          svix_signature: signature
        },
        webhook_secret: secret_without_prefix
      )

      expect(result).to be true
    end

    it "should raise error for invalid base64 secret" do
      expect {
        Resend::Webhooks.verify(
          payload: payload,
          headers: {
            svix_id: msg_id,
            svix_timestamp: timestamp,
            svix_signature: "v1,sig"
          },
          webhook_secret: "whsec_not_valid_base64!!!"
        )
      }.to raise_error(/Failed to decode webhook secret/)
    end
  end

end
