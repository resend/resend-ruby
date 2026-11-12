# frozen_string_literal: true

RSpec.describe "Domains::Forge" do
  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  let(:domain_id) { "d91cd9bd-1176-453e-8fc1-35364d380206" }

  let(:forge_domain) do
    {
      object: "domain",
      id: "d91cd9bd-1176-453e-8fc1-35364d380206",
      name: "example.com",
      status: "pending",
      created_at: "2026-11-11 10:00:00.000000+00",
      region: "us-east-1",
      capabilities: {
        "sending" => "enabled",
        "receiving" => "disabled"
      },
      records: [
        {
          "record" => "SPF",
          "name" => "send",
          "value" => "v=spf1 include:spf.resend.com ~all",
          "type" => "TXT",
          "ttl" => "Auto",
          "status" => "pending"
        },
        {
          "record" => "DKIM",
          "name" => "resend._domainkey",
          "value" => "resend._domainkey.example.com.dkim.resend.com.",
          "type" => "CNAME",
          "ttl" => "Auto",
          "status" => "pending"
        }
      ],
      open_tracking: false,
      click_tracking: false
    }
  end

  describe "enable" do
    it "activates Forge and returns the full domain" do
      params = { id: domain_id, return_path: "send" }

      expect(Resend::Request).to receive(:new)
        .with("domains/#{domain_id}/forge", { return_path: "send" }, "post")
        .and_call_original
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(forge_domain)

      domain = Resend::Domains::Forge.enable(params)

      expect(domain[:object]).to eql("domain")
      expect(domain[:id]).to eql(domain_id)
      expect(domain[:status]).to eql("pending")
      expect(domain[:records].first["record"]).to eql("SPF")
    end

    it "activates Forge without a return path" do
      expect(Resend::Request).to receive(:new)
        .with("domains/#{domain_id}/forge", {}, "post")
        .and_call_original
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(forge_domain)

      domain = Resend::Domains::Forge.enable({ id: domain_id })

      expect(domain[:object]).to eql("domain")
      expect(domain[:id]).to eql(domain_id)
    end
  end
end
