# frozen_string_literal: true

RSpec.describe "Domains::Claims" do
  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  describe "create" do
    it "should start a domain claim" do
      resp = {
        object: "domain_claim",
        id: "dacf4072-4119-4d88-932f-6c6126d3a9d1",
        name: "example.com",
        status: "pending",
        domain_id: "d91cd9bd-1176-453e-8fc1-35364d380206",
        region: "us-east-1",
        record: {
          "type" => "TXT",
          "name" => "example.com",
          "value" => "resend-domain-verification=3f8a1c2d4e5b6a7f8091a2b3c4d5e6f7",
          "ttl" => "Auto"
        },
        blocked_reason: nil,
        failure_reason: nil,
        created_at: "2026-06-16 17:12:02.059593+00",
        expires_at: "2026-06-23 17:12:02.059593+00"
      }

      params = { name: "example.com" }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      claim = Resend::Domains::Claims.create(params)
      expect(claim[:id]).to eql("dacf4072-4119-4d88-932f-6c6126d3a9d1")
      expect(claim[:object]).to eql("domain_claim")
      expect(claim[:status]).to eql("pending")
      expect(claim[:domain_id]).to eql("d91cd9bd-1176-453e-8fc1-35364d380206")
      expect(claim[:record]["type"]).to eql("TXT")
      expect(claim[:record]["value"]).to eql("resend-domain-verification=3f8a1c2d4e5b6a7f8091a2b3c4d5e6f7")
    end

    it "should pass all options in the request body" do
      resp = { object: "domain_claim", id: "dacf4072-4119-4d88-932f-6c6126d3a9d1", status: "pending" }

      params = {
        name: "example.com",
        region: "us-east-1",
        custom_return_path: "send",
        open_tracking: true,
        click_tracking: false,
        tracking_subdomain: "links"
      }

      expect(Resend::Request).to receive(:new).with("domains/claim", params, "post").and_call_original
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      Resend::Domains::Claims.create(params)
    end
  end

  describe "get" do
    it "should retrieve a domain claim" do
      resp = {
        object: "domain_claim",
        id: "dacf4072-4119-4d88-932f-6c6126d3a9d1",
        name: "example.com",
        status: "blocked",
        domain_id: "d91cd9bd-1176-453e-8fc1-35364d380206",
        region: "us-east-1",
        blocked_reason: "grace_period",
        failure_reason: nil,
        created_at: "2026-06-16 17:12:02.059593+00",
        expires_at: "2026-06-23 17:12:02.059593+00"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      claim = Resend::Domains::Claims.get(resp[:domain_id])

      expect(claim[:id]).to eql("dacf4072-4119-4d88-932f-6c6126d3a9d1")
      expect(claim[:status]).to eql("blocked")
      expect(claim[:blocked_reason]).to eql("grace_period")
    end
  end

  describe "verify" do
    it "should trigger verification for a domain claim" do
      resp = {
        object: "domain_claim",
        id: "dacf4072-4119-4d88-932f-6c6126d3a9d1",
        name: "example.com",
        status: "pending",
        domain_id: "d91cd9bd-1176-453e-8fc1-35364d380206",
        region: "us-east-1"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      claim = Resend::Domains::Claims.verify("d91cd9bd-1176-453e-8fc1-35364d380206")
      expect(claim[:id]).to eql("dacf4072-4119-4d88-932f-6c6126d3a9d1")
      expect(claim[:status]).to eql("pending")
    end
  end
end
