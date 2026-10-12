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
      resp = { object: "inbox_agent", instructions: nil, tone: nil, enabled_actions: [] }
      expect_request("inboxes/#{inbox_id}/agent", {}, "get", resp)

      agent = Resend::Inboxes::Agent.get(inbox_id: inbox_id)
      expect(agent[:instructions]).to be_nil
      expect(agent[:enabled_actions]).to eql([])
    end

    it "should raise when inbox_id is missing" do
      expect { Resend::Inboxes::Agent.get({}) }.to raise_error(ArgumentError, "inbox_id is required")
    end
  end

  describe "update" do
    it "should update the agent settings and keep explicit nils" do
      body = { instructions: nil, tone: "friendly and concise", enabled_actions: %w[draft_reply add_labels] }
      resp = { object: "inbox_agent", instructions: nil, tone: "friendly and concise",
               enabled_actions: %w[draft_reply add_labels] }
      expect_request("inboxes/#{inbox_id}/agent", body, "patch", resp)

      agent = Resend::Inboxes::Agent.update(inbox_id: inbox_id, **body)
      expect(agent[:tone]).to eql("friendly and concise")
    end

    it "should raise when inbox_id is missing" do
      expect { Resend::Inboxes::Agent.update(tone: "formal") }.to raise_error(ArgumentError, "inbox_id is required")
    end
  end
end
