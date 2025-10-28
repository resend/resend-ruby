# frozen_string_literal: true

RSpec.describe "Attachments" do
  before do
    Resend.api_key = "re_123"
  end

  describe "get" do
    it "should retrieve an attachment from a sent email" do
      resp = {
        "object" => "attachment",
        "id" => "2a0c9ce0-3112-4728-976e-47ddcd16a318",
        "filename" => "invoice.pdf",
        "content_type" => "application/pdf",
        "content_disposition" => "attachment",
        "content_id" => "doc001",
        "download_url" => "https://cdn.resend.com/4ef9a417-02e9-4d39-ad75-9611e0fcc33c/attachments/2a0c9ce0-3112-4728-976e-47ddcd16a318?some-params=example&signature=sig-123",
        "expires_at" => "2025-10-17T14:29:41.521Z"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      attachment = Resend::Attachments.get(
        id: "2a0c9ce0-3112-4728-976e-47ddcd16a318",
        email_id: "4ef9a417-02e9-4d39-ad75-9611e0fcc33c"
      )

      expect(attachment[:object]).to eql("attachment")
      expect(attachment[:id]).to eql("2a0c9ce0-3112-4728-976e-47ddcd16a318")
      expect(attachment[:filename]).to eql("invoice.pdf")
      expect(attachment[:content_type]).to eql("application/pdf")
      expect(attachment[:download_url]).to include("cdn.resend.com")
    end

    it "should call the correct API endpoint" do
      resp = {
        "object" => "attachment",
        "id" => "2a0c9ce0-3112-4728-976e-47ddcd16a318"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Attachments.get(
        id: "2a0c9ce0-3112-4728-976e-47ddcd16a318",
        email_id: "4ef9a417-02e9-4d39-ad75-9611e0fcc33c"
      )

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/4ef9a417-02e9-4d39-ad75-9611e0fcc33c/attachments/2a0c9ce0-3112-4728-976e-47ddcd16a318",
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

    it "should raise an error when attachment is not found" do
      resp = {
        "statusCode" => 404,
        "name" => "not_found",
        "message" => "Attachment not found"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      expect {
        Resend::Attachments.get(
          id: "invalid_id",
          email_id: "invalid_email_id"
        )
      }.to raise_error(
        Resend::Error::InvalidRequestError,
        /Attachment not found/
      )
    end
  end

  describe "list" do
    it "should list attachments from a sent email without parameters" do
      resp = {
        "object" => "list",
        "has_more" => false,
        "data" => [
          {
            "id" => "2a0c9ce0-3112-4728-976e-47ddcd16a318",
            "filename" => "invoice.pdf",
            "content_type" => "application/pdf",
            "content_disposition" => "attachment",
            "content_id" => "doc001",
            "download_url" => "https://cdn.resend.com/4ef9a417-02e9-4d39-ad75-9611e0fcc33c/attachments/2a0c9ce0-3112-4728-976e-47ddcd16a318?some-params=example&signature=sig-123",
            "expires_at" => "2025-10-17T14:29:41.521Z"
          }
        ]
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      result = Resend::Attachments.list(
        email_id: "4ef9a417-02e9-4d39-ad75-9611e0fcc33c"
      )

      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to eql(false)
      expect(result[:data].length).to eql(1)
      expect(result[:data].first["filename"]).to eql("invoice.pdf")
    end

    it "should list attachments with limit parameter" do
      resp = {
        "object" => "list",
        "has_more" => false,
        "data" => []
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      result = Resend::Attachments.list(
        email_id: "4ef9a417-02e9-4d39-ad75-9611e0fcc33c",
        limit: 50
      )

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/4ef9a417-02e9-4d39-ad75-9611e0fcc33c/attachments",
        hash_including(
          query: { limit: 50 }
        )
      )
      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to eql(false)
    end

    it "should list attachments with pagination parameters" do
      resp = {
        "object" => "list",
        "has_more" => true,
        "data" => []
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      result = Resend::Attachments.list(
        email_id: "4ef9a417-02e9-4d39-ad75-9611e0fcc33c",
        limit: 20,
        after: "cursor_123",
        before: "cursor_456"
      )

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/4ef9a417-02e9-4d39-ad75-9611e0fcc33c/attachments",
        hash_including(
          query: { limit: 20, after: "cursor_123", before: "cursor_456" }
        )
      )
      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to eql(true)
    end

    it "should call the correct API endpoint for list" do
      resp = {
        "object" => "list",
        "has_more" => false,
        "data" => []
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Attachments.list(
        email_id: "4ef9a417-02e9-4d39-ad75-9611e0fcc33c"
      )

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/4ef9a417-02e9-4d39-ad75-9611e0fcc33c/attachments",
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
  end
end
