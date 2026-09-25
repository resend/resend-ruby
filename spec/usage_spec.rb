# frozen_string_literal: true

RSpec.describe "Usage" do
  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  describe "get" do
    it "should retrieve account usage" do
      resp = {
        object: "usage",
        emails: {
          daily: { used: 258, limit: nil, sent: 57, received: 201, resets_at: "2026-07-17T00:00:00.000Z" },
          monthly: { used: 5422, limit: 10_000, sent: 1000, received: 4442, resets_at: "2026-08-01T00:00:00.000Z" }
        },
        contacts: { used: 85_000, limit: 150_000 },
        segments: { used: 2, limit: 3 },
        broadcasts: { used: 100, limit: nil },
        ai_credits: { used: 0, limit: 500, next_increase_at: "2026-07-18T09:00:00.000Z" },
        automation_runs: { used: 0, limit: 1000, resets_at: "2026-08-01T00:00:00.000Z" },
        domains: { used: 1, limit: 1000 },
        rate_limit: { limit: 10, duration: "1000ms" }
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      result = Resend::Usage.get

      expect(result[:object]).to eql("usage")
      expect(result[:emails][:daily][:limit]).to be_nil
      expect(result[:emails][:monthly][:limit]).to eql(10_000)
      expect(result[:broadcasts][:limit]).to be_nil
      expect(result[:ai_credits][:next_increase_at]).to eql("2026-07-18T09:00:00.000Z")
      expect(result[:rate_limit]).to eql({ limit: 10, duration: "1000ms" })
    end

    it "should use GET /usage with no params" do
      req = double("req", perform: { object: "usage" })
      expect(Resend::Request).to receive(:new).once do |path, body, verb|
        expect(path).to eql("usage")
        expect(body).to eql({})
        expect(verb).to eql("get")
        req
      end
      Resend::Usage.get
    end
  end
end
