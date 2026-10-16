# frozen_string_literal: true

RSpec.describe "Inboxes::Labels" do
  let(:inbox_id) { "b3e2b2b6-3f0e-4c8e-9ad3-2f43a1e2c7f1" }
  let(:label_id) { "7f9c1d2e-4a6b-4c3d-8e15-9b0a7c6d5e34" }

  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  def expect_request(path, body, verb, resp)
    expect(Resend::Request).to receive(:new).with(path, body, verb).and_return(double("req", perform: resp))
  end

  describe "list" do
    it "should list labels" do
      resp = {
        object: "list",
        data: [{ "id" => label_id, "name" => "Urgent", "color" => "#E93D82", "created_at" => "2026-09-01T00:00:00.000Z" }]
      }
      expect_request("inboxes/#{inbox_id}/labels", {}, "get", resp)

      labels = Resend::Inboxes::Labels.list(inbox_id: inbox_id)
      expect(labels[:data].first["color"]).to eql("#E93D82")
    end

    it "should raise when inbox_id is missing" do
      expect { Resend::Inboxes::Labels.list({}) }.to raise_error(ArgumentError, "inbox_id is required")
    end
  end

  describe "create" do
    it "should create a label" do
      expect_request("inboxes/#{inbox_id}/labels", { name: "Urgent", color: "#E93D82" }, "post",
                     { object: "inbox_label", id: label_id })

      label = Resend::Inboxes::Labels.create(inbox_id: inbox_id, name: "Urgent", color: "#E93D82")
      expect(label[:id]).to eql(label_id)
    end
  end

  describe "update" do
    it "should update a label" do
      expect_request("inboxes/#{inbox_id}/labels/#{label_id}", { color: "#F76B15" }, "patch",
                     { object: "inbox_label", id: label_id })

      label = Resend::Inboxes::Labels.update(inbox_id: inbox_id, label_id: label_id, color: "#F76B15")
      expect(label[:id]).to eql(label_id)
    end

    it "should raise when label_id is missing" do
      expect do
        Resend::Inboxes::Labels.update(inbox_id: inbox_id, name: "Billing")
      end.to raise_error(ArgumentError, "label_id is required")
    end
  end

  describe "remove" do
    it "should remove a label" do
      expect_request("inboxes/#{inbox_id}/labels/#{label_id}", {}, "delete",
                     { object: "inbox_label", id: label_id, deleted: true })

      label = Resend::Inboxes::Labels.remove(inbox_id: inbox_id, label_id: label_id)
      expect(label[:deleted]).to be true
    end

    it "should raise when label_id is missing" do
      expect do
        Resend::Inboxes::Labels.remove(inbox_id: inbox_id)
      end.to raise_error(ArgumentError, "label_id is required")
    end
  end
end
