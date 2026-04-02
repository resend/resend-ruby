# frozen_string_literal: true

RSpec.describe "Logs" do
  context "static api_key" do
    before do
      Resend.configure do |config|
        config.api_key = "re_123"
      end
    end

    describe "get" do
      it "should retrieve a log" do
        resp = {
          "object": "log",
          "id": "3d4a472d-bc6d-4dd2-aa9d-d3d11b549e55",
          "created_at": "2024-11-01T18:10:00.000Z",
          "endpoint": "/emails",
          "method": "POST",
          "response_status": 200,
          "user_agent": "resend-ruby:1.0.0",
          "request_body": { "from": "user@example.com", "to": "recipient@example.com" },
          "response_body": { "id": "email_123" }
        }
        allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
        result = Resend::Logs.get("3d4a472d-bc6d-4dd2-aa9d-d3d11b549e55")
        expect(result[:id]).to eql("3d4a472d-bc6d-4dd2-aa9d-d3d11b549e55")
        expect(result[:object]).to eql("log")
        expect(result[:endpoint]).to eql("/emails")
        expect(result[:method]).to eql("POST")
        expect(result[:response_status]).to eql(200)
      end

      it "should handle nullable user_agent" do
        resp = {
          "object": "log",
          "id": "3d4a472d-bc6d-4dd2-aa9d-d3d11b549e55",
          "created_at": "2024-11-01T18:10:00.000Z",
          "endpoint": "/emails",
          "method": "POST",
          "response_status": 200,
          "user_agent": nil,
          "request_body": {},
          "response_body": {}
        }
        allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
        result = Resend::Logs.get("3d4a472d-bc6d-4dd2-aa9d-d3d11b549e55")
        expect(result[:user_agent]).to be_nil
      end

      it "should raise when log is not found" do
        resp = {
          "statusCode" => 404,
          "name" => "not_found",
          "message" => "Log not found"
        }
        allow(resp).to receive(:body).and_return(resp)
        allow(HTTParty).to receive(:send).and_return(resp)
        expect { Resend::Logs.get("missing-id") }.to raise_error(Resend::Error::InvalidRequestError, /Log not found/)
      end

      it "should raise when log_id is not a valid UUID" do
        resp = {
          "statusCode" => 422,
          "name" => "validation_error",
          "message" => "The `logId` must be a valid UUID."
        }
        allow(resp).to receive(:body).and_return(resp)
        allow(HTTParty).to receive(:send).and_return(resp)
        expect { Resend::Logs.get("not-a-uuid") }.to raise_error(Resend::Error::InvalidRequestError, /must be a valid UUID/)
      end
    end

    describe "list" do
      it "should list logs" do
        resp = {
          "object": "list",
          "has_more": false,
          "data": [
            {
              "id": "3d4a472d-bc6d-4dd2-aa9d-d3d11b549e55",
              "created_at": "2024-11-01T18:10:00.000Z",
              "endpoint": "/emails",
              "method": "POST",
              "response_status": 200,
              "user_agent": "resend-ruby:1.0.0"
            },
            {
              "id": "4e5b583e-cd7e-5ee3-bbae-e4e22c650f66",
              "created_at": "2024-11-01T17:00:00.000Z",
              "endpoint": "/emails",
              "method": "POST",
              "response_status": 422,
              "user_agent": nil
            }
          ]
        }
        allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
        result = Resend::Logs.list
        expect(result[:data].length).to eql(2)
        expect(result[:has_more]).to eql(false)
        expect(result[:data].first[:id]).to eql("3d4a472d-bc6d-4dd2-aa9d-d3d11b549e55")
        expect(result[:data].last[:user_agent]).to be_nil
      end

      it "should list logs with pagination params" do
        resp = {
          "object": "list",
          "has_more": true,
          "data": [
            {
              "id": "3d4a472d-bc6d-4dd2-aa9d-d3d11b549e55",
              "created_at": "2024-11-01T18:10:00.000Z",
              "endpoint": "/emails",
              "method": "POST",
              "response_status": 200,
              "user_agent": "resend-ruby:1.0.0"
            }
          ]
        }
        allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
        result = Resend::Logs.list({ limit: 1 })
        expect(result[:data].length).to eql(1)
        expect(result[:has_more]).to eql(true)
      end
    end
  end

  context "dynamic api_key" do
    before do
      Resend.configure do |config|
        config.api_key = -> { "re_123" }
      end
    end

    describe "get" do
      it "should retrieve a log" do
        resp = {
          "object": "log",
          "id": "3d4a472d-bc6d-4dd2-aa9d-d3d11b549e55",
          "created_at": "2024-11-01T18:10:00.000Z",
          "endpoint": "/emails",
          "method": "POST",
          "response_status": 200,
          "user_agent": "resend-ruby:1.0.0",
          "request_body": {},
          "response_body": {}
        }
        allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
        result = Resend::Logs.get("3d4a472d-bc6d-4dd2-aa9d-d3d11b549e55")
        expect(result[:id]).to eql("3d4a472d-bc6d-4dd2-aa9d-d3d11b549e55")
      end
    end

    describe "list" do
      it "should list logs" do
        resp = {
          "object": "list",
          "has_more": false,
          "data": [
            {
              "id": "3d4a472d-bc6d-4dd2-aa9d-d3d11b549e55",
              "created_at": "2024-11-01T18:10:00.000Z",
              "endpoint": "/emails",
              "method": "POST",
              "response_status": 200,
              "user_agent": "resend-ruby:1.0.0"
            }
          ]
        }
        allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
        result = Resend::Logs.list
        expect(result[:data].length).to eql(1)
      end
    end
  end
end
