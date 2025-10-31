# frozen_string_literal: true

RSpec.describe "Contacts::Segments" do

  let(:contact_id) { "e169aa45-1ecf-4183-9955-b1499d5701d3" }
  let(:segment_id) { "78b8d3bc-a55a-45a3-aee6-6ec0a5e13d7e" }

  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  describe "list contact segments" do
    it "should list segments for a contact using contact_id" do
      resp = {
        "object": "list",
        "data": [
          {
            "id": segment_id,
            "name": "Registered Users",
            "created_at": "2023-10-06T22:59:55.977Z"
          }
        ]
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      segments = Resend::Contacts::Segments.list(contact_id: contact_id)
      expect(segments[:object]).to eql "list"
      expect(segments[:data].length).to eql 1
      expect(segments[:data][0][:id]).to eql segment_id
      expect(segments[:data][0][:name]).to eql "Registered Users"
    end

    it "should list segments for a contact using email" do
      resp = {
        "object": "list",
        "data": []
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      segments = Resend::Contacts::Segments.list(email: "steve@example.com")
      expect(segments[:object]).to eql "list"
      expect(segments[:data].length).to eql 0
    end

    it "should raise error when contact_id and email are both missing" do
      expect {
        Resend::Contacts::Segments.list({})
      }.to raise_error(ArgumentError, "contact_id or email is required")
    end

    it "should support pagination parameters" do
      resp = {
        "object": "list",
        "data": [
          {
            "id": segment_id,
            "name": "Registered Users",
            "created_at": "2023-10-06T22:59:55.977Z"
          }
        ],
        "has_more": true
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      segments = Resend::Contacts::Segments.list(
        contact_id: contact_id,
        limit: 10,
        after: "cursor123"
      )
      expect(segments[:object]).to eql "list"
      expect(segments[:data].length).to eql 1
      expect(segments[:has_more]).to be true
    end
  end

  describe "add contact to segment" do
    it "should add a contact to a segment using contact_id" do
      resp = {
        "id": segment_id
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Contacts::Segments.add(
        contact_id: contact_id,
        segment_id: segment_id
      )
      expect(result[:id]).to eql segment_id
    end

    it "should add a contact to a segment using email" do
      resp = {
        "id": segment_id
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Contacts::Segments.add(
        email: "steve@example.com",
        segment_id: segment_id
      )
      expect(result[:id]).to eql segment_id
    end

    it "should raise error when contact_id and email are both missing" do
      expect {
        Resend::Contacts::Segments.add(segment_id: segment_id)
      }.to raise_error(ArgumentError, "contact_id or email is required")
    end

    it "should raise error when segment_id is missing" do
      expect {
        Resend::Contacts::Segments.add(contact_id: contact_id)
      }.to raise_error(ArgumentError, "segment_id is required")
    end
  end

  describe "remove contact from segment" do
    it "should remove a contact from a segment using contact_id" do
      resp = {
        "id": segment_id,
        "deleted": true
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Contacts::Segments.remove(
        contact_id: contact_id,
        segment_id: segment_id
      )
      expect(result[:id]).to eql segment_id
      expect(result[:deleted]).to be true
    end

    it "should remove a contact from a segment using email" do
      resp = {
        "id": segment_id,
        "deleted": true
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Contacts::Segments.remove(
        email: "steve@example.com",
        segment_id: segment_id
      )
      expect(result[:id]).to eql segment_id
      expect(result[:deleted]).to be true
    end

    it "should raise error when contact_id and email are both missing" do
      expect {
        Resend::Contacts::Segments.remove(segment_id: segment_id)
      }.to raise_error(ArgumentError, "contact_id or email is required")
    end

    it "should raise error when segment_id is missing" do
      expect {
        Resend::Contacts::Segments.remove(contact_id: contact_id)
      }.to raise_error(ArgumentError, "segment_id is required")
    end
  end
end
