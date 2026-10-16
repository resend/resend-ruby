# frozen_string_literal: true

RSpec.describe "Inboxes::Agent" do
  let(:inbox_id) { "b3e2b2b6-3f0e-4c8e-9ad3-2f43a1e2c7f1" }

  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  def expect_request(path, body, verb, resp)
    expect(Resend::Request).to receive(:new).with(path, body, verb).and_return(double("req", perform: resp))
  end

  describe "get" do
    it "should retrieve the agent settings" do
      resp = { object: "inbox_agent", instructions: nil, tone: nil, actions: [] }
      expect_request("inboxes/#{inbox_id}/agent", {}, "get", resp)

      agent = Resend::Inboxes::Agent.get(inbox_id: inbox_id)
      expect(agent[:instructions]).to be_nil
      expect(agent[:actions]).to eql([])
    end

    it "should accept the inbox email address" do
      expect_request("inboxes/support%40acme.com/agent", {}, "get", { object: "inbox_agent" })

      Resend::Inboxes::Agent.get(inbox_id: "support@acme.com")
    end

    it "should raise when inbox_id is missing" do
      expect { Resend::Inboxes::Agent.get({}) }.to raise_error(ArgumentError, "inbox_id is required")
    end
  end

  describe "update" do
    it "should update the agent settings and keep explicit nils" do
      body = { instructions: nil, tone: "concise_casual", actions: %w[draft_reply archive move_to_trash] }
      resp = { object: "inbox_agent", id: "a1f84a4e-6f2b-4f0a-9c1d-8a2e5b3c7d90" }
      expect_request("inboxes/#{inbox_id}/agent", body, "patch", resp)

      agent = Resend::Inboxes::Agent.update(inbox_id: inbox_id, **body)
      expect(agent[:object]).to eql("inbox_agent")
    end

    it "should raise when inbox_id is missing" do
      expect { Resend::Inboxes::Agent.update(tone: "formal") }.to raise_error(ArgumentError, "inbox_id is required")
    end
  end
end
