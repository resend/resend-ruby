# frozen_string_literal: true

RSpec.describe "ContactProperties" do

  let(:property_id) { "cp_123abc" }

  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  describe "create contact property" do
    it "should create a contact property" do
      resp = {
        "object": "contact_property",
        "id": property_id
      }

      params = {
        key: "user_tier",
        type: "string",
        fallback_value: "free"
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      property = Resend::ContactProperties.create(params)
      expect(property[:id]).to eql(property_id)
      expect(property[:object]).to eql("contact_property")
    end
  end

  describe "list contact properties" do
    it "should list all contact properties" do
      resp = {
        "object": "list",
        "data": [
          {
            "id": property_id,
            "key": "user_tier",
            "type": "string",
            "fallback_value": "free",
            "created_at": "2023-10-06T23:47:56.678Z"
          }
        ]
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      properties = Resend::ContactProperties.list
      expect(properties[:object]).to eql "list"
      expect(properties[:data].length).to eql 1
      expect(properties[:data][0][:id]).to eql property_id
      expect(properties[:data][0][:key]).to eql "user_tier"
    end

    it "should support pagination parameters" do
      resp = {
        "object": "list",
        "data": [
          {
            "id": property_id,
            "key": "user_tier",
            "type": "string",
            "fallback_value": "free",
            "created_at": "2023-10-06T23:47:56.678Z"
          }
        ],
        "has_more": true
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      properties = Resend::ContactProperties.list(limit: 10, after: "cursor123")
      expect(properties[:object]).to eql "list"
      expect(properties[:data].length).to eql 1
      expect(properties[:has_more]).to be true
    end
  end

  describe "get contact property" do
    it "should retrieve a contact property by id" do
      resp = {
        "object": "contact_property",
        "id": property_id,
        "key": "user_tier",
        "type": "string",
        "fallback_value": "free",
        "created_at": "2023-10-06T23:47:56.678Z"
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      property = Resend::ContactProperties.get(property_id)

      expect(property[:object]).to eql "contact_property"
      expect(property[:id]).to eql property_id
      expect(property[:key]).to eql "user_tier"
      expect(property[:type]).to eql "string"
      expect(property[:fallback_value]).to eql "free"
    end
  end

  describe "update contact property" do
    it "should update a contact property" do
      resp = {
        "object": "contact_property",
        "id": property_id
      }

      update_params = {
        id: property_id,
        fallback_value: "premium"
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      property = Resend::ContactProperties.update(update_params)
      expect(property[:id]).to eql(property_id)
      expect(property[:object]).to eql("contact_property")
    end

    it "should raise error when id is missing" do
      expect {
        Resend::ContactProperties.update({ fallback_value: "premium" })
      }.to raise_error(ArgumentError, "id is required")
    end
  end

  describe "remove contact property" do
    it "should remove a contact property by id" do
      resp = {
        "object": "contact_property",
        "id": property_id,
        "deleted": true
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      deleted = Resend::ContactProperties.remove(property_id)
      expect(deleted[:object]).to eql("contact_property")
      expect(deleted[:id]).to eql(property_id)
      expect(deleted[:deleted]).to be true
    end
  end
end
