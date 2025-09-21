# frozen_string_literal: true

RSpec.describe "Pagination" do
  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  describe "PaginationHelper" do
    describe ".build_paginated_path" do
      it "returns base path when no query params provided" do
        path = Resend::PaginationHelper.build_paginated_path("api-keys")
        expect(path).to eq("api-keys")
      end

      it "returns base path when empty query params provided" do
        path = Resend::PaginationHelper.build_paginated_path("api-keys", {})
        expect(path).to eq("api-keys")
      end

      it "builds path with limit parameter" do
        path = Resend::PaginationHelper.build_paginated_path("api-keys", { limit: 10 })
        expect(path).to eq("api-keys?limit=10")
      end

      it "builds path with after parameter" do
        path = Resend::PaginationHelper.build_paginated_path("api-keys", { after: "key_123" })
        expect(path).to eq("api-keys?after=key_123")
      end

      it "builds path with before parameter" do
        path = Resend::PaginationHelper.build_paginated_path("api-keys", { before: "key_456" })
        expect(path).to eq("api-keys?before=key_456")
      end

      it "builds path with multiple parameters" do
        path = Resend::PaginationHelper.build_paginated_path("api-keys", { limit: 25, after: "key_123" })
        expect(path).to include("limit=25")
        expect(path).to include("after=key_123")
        expect(path).to include("api-keys?")
        expect(path).to include("&")
      end

      it "URL encodes parameter values" do
        path = Resend::PaginationHelper.build_paginated_path("api-keys", { after: "key with spaces" })
        expect(path).to eq("api-keys?after=key+with+spaces")
      end

      it "filters out nil values" do
        path = Resend::PaginationHelper.build_paginated_path("api-keys", { limit: 10, after: nil, before: "key_123" })
        expect(path).to include("limit=10")
        expect(path).to include("before=key_123")
        expect(path).not_to include("after")
      end

      it "raises error for invalid limit" do
        expect {
          Resend::PaginationHelper.build_paginated_path("api-keys", { limit: 0 })
        }.to raise_error(ArgumentError, "limit must be between 1 and 100")

        expect {
          Resend::PaginationHelper.build_paginated_path("api-keys", { limit: 101 })
        }.to raise_error(ArgumentError, "limit must be between 1 and 100")
      end
    end
  end

  describe "ApiKeys.list with pagination" do
    it "should accept pagination parameters" do
      resp = {
        "object": "list",
        "data": [
          {
            "id": "6e3c3d83-05dc-4b51-acfc-fe8972738bd0",
            "name": "test1",
            "created_at": "2023-04-21T01:31:02.671414+00:00"
          }
        ],
        "has_more": true
      }

      request_instance = instance_double(Resend::Request)
      allow(request_instance).to receive(:perform).and_return(resp)
      allow(Resend::Request).to receive(:new) do |path, body, verb|
        expect(path).to include("limit=10")
        expect(path).to include("after=key_123")
        request_instance
      end

      params = { limit: 10, after: "key_123" }
      result = Resend::ApiKeys.list(params)
      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to be true
      expect(result[:data].length).to eql(1)
    end
  end

  describe "Audiences.list with pagination" do
    it "should accept pagination parameters" do
      resp = {
        "object": "list",
        "data": [
          {
            "id": "78261eea-8f8b-4381-83c6-79fa7120f1cf",
            "name": "Developers"
          }
        ],
        "has_more": false
      }

      request_instance = instance_double(Resend::Request)
      allow(request_instance).to receive(:perform).and_return(resp)
      allow(Resend::Request).to receive(:new) do |path, body, verb|
        expect(path).to include("limit=5")
        request_instance
      end

      params = { limit: 5 }
      result = Resend::Audiences.list(params)
      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to be false
    end
  end

  describe "Broadcasts.list with pagination" do
    it "should accept pagination parameters" do
      resp = {
        "object": "list",
        "data": [
          {
            "id": "b6d24b8e-af0b-4c3c-be0c-359bf9d251d2",
            "name": "Weekly Newsletter"
          }
        ],
        "has_more": true
      }

      request_instance = instance_double(Resend::Request)
      allow(request_instance).to receive(:perform).and_return(resp)
      allow(Resend::Request).to receive(:new) do |path, body, verb|
        expect(path).to include("before=broadcast_456")
        request_instance
      end

      params = { before: "broadcast_456" }
      result = Resend::Broadcasts.list(params)
      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to be true
    end
  end

  describe "Contacts.list with pagination" do
    it "should accept pagination parameters" do
      resp = {
        "object": "list",
        "data": [
          {
            "id": "e169aa45-1ecf-4183-9955-b1499d5701d3",
            "email": "steve.wozniak@gmail.com"
          }
        ],
        "has_more": false
      }

      request_instance = instance_double(Resend::Request)
      allow(request_instance).to receive(:perform).and_return(resp)
      allow(Resend::Request).to receive(:new) do |path, body, verb|
        expect(path).to include("audiences/audience_123/contacts")
        expect(path).to include("limit=20")
        request_instance
      end

      params = { limit: 20 }
      result = Resend::Contacts.list("audience_123", params)
      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to be false
    end
  end

  describe "Domains.list with pagination" do
    it "should accept pagination parameters" do
      resp = {
        "object": "list",
        "data": [
          {
            "id": "d91cd9bd-1176-453e-8fc1-35364d380206",
            "name": "example.com"
          }
        ],
        "has_more": true
      }

      request_instance = instance_double(Resend::Request)
      allow(request_instance).to receive(:perform).and_return(resp)
      allow(Resend::Request).to receive(:new) do |path, body, verb|
        expect(path).to include("limit=50")
        expect(path).to include("after=domain_789")
        request_instance
      end

      params = { limit: 50, after: "domain_789" }
      result = Resend::Domains.list(params)
      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to be true
    end
  end
end