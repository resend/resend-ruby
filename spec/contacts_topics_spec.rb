# frozen_string_literal: true

RSpec.describe "Contacts::Topics" do

  let(:contact_id) { "e169aa45-1ecf-4183-9955-b1499d5701d3" }
  let(:topic_id) { "tp_123abc" }

  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  describe "list contact topics" do
    it "should list topics for a contact using contact_id" do
      resp = {
        "object": "list",
        "data": [
          {
            "id": topic_id,
            "name": "Product Updates",
            "created_at": "2023-10-06T22:59:55.977Z"
          }
        ]
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      topics = Resend::Contacts::Topics.list(contact_id: contact_id)
      expect(topics[:object]).to eql "list"
      expect(topics[:data].length).to eql 1
      expect(topics[:data][0][:id]).to eql topic_id
      expect(topics[:data][0][:name]).to eql "Product Updates"
    end

    it "should list topics for a contact using email" do
      resp = {
        "object": "list",
        "data": []
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      topics = Resend::Contacts::Topics.list(email: "steve@example.com")
      expect(topics[:object]).to eql "list"
      expect(topics[:data].length).to eql 0
    end

    it "should raise error when contact_id and email are both missing" do
      expect {
        Resend::Contacts::Topics.list({})
      }.to raise_error(ArgumentError, "contact_id or email is required")
    end

    it "should support pagination parameters" do
      resp = {
        "object": "list",
        "data": [
          {
            "id": topic_id,
            "name": "Product Updates",
            "created_at": "2023-10-06T22:59:55.977Z"
          }
        ],
        "has_more": true
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      topics = Resend::Contacts::Topics.list(
        contact_id: contact_id,
        limit: 10,
        after: "cursor123"
      )
      expect(topics[:object]).to eql "list"
      expect(topics[:data].length).to eql 1
      expect(topics[:has_more]).to be true
    end
  end

  describe "update contact topics" do
    it "should update topics for a contact using contact_id" do
      resp = {
        "object": "contact",
        "id": contact_id
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Contacts::Topics.update(
        contact_id: contact_id,
        topics: [topic_id, "tp_456def"]
      )
      expect(result[:id]).to eql contact_id
      expect(result[:object]).to eql "contact"
    end

    it "should update topics for a contact using email" do
      resp = {
        "object": "contact",
        "id": contact_id
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Contacts::Topics.update(
        email: "steve@example.com",
        topics: [topic_id]
      )
      expect(result[:id]).to eql contact_id
      expect(result[:object]).to eql "contact"
    end

    it "should raise error when contact_id and email are both missing" do
      expect {
        Resend::Contacts::Topics.update(topics: [topic_id])
      }.to raise_error(ArgumentError, "contact_id or email is required")
    end
  end
end
