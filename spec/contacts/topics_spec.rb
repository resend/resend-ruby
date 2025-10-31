# frozen_string_literal: true

RSpec.describe "Contacts::Topics" do
  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  describe "list contact topics" do
    it "should list topics by contact id" do
      resp = {
        object: "list",
        has_more: false,
        data: [
          {
            id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
            name: "Product Updates",
            description: "New features, and latest announcements.",
            subscription: "opt_in"
          }
        ]
      }

      contact_id = "e169aa45-1ecf-4183-9955-b1499d5701d3"
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      topics = Resend::Contacts::Topics.list(id: contact_id)

      expect(topics[:object]).to eql("list")
      expect(topics[:has_more]).to eql(false)
      expect(topics[:data]).to be_an(Array)
      expect(topics[:data].first[:id]).to eql("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")
      expect(topics[:data].first[:subscription]).to eql("opt_in")
    end

    it "should list topics by contact email" do
      resp = {
        object: "list",
        has_more: false,
        data: [
          {
            id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
            name: "Product Updates",
            description: "New features, and latest announcements.",
            subscription: "opt_in"
          }
        ]
      }

      contact_email = "steve.wozniak@gmail.com"
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      topics = Resend::Contacts::Topics.list(email: contact_email)

      expect(topics[:object]).to eql("list")
      expect(topics[:data]).to be_an(Array)
    end

    it "should list topics with pagination parameters" do
      resp = {
        object: "list",
        has_more: true,
        data: []
      }

      contact_id = "e169aa45-1ecf-4183-9955-b1499d5701d3"

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      topics = Resend::Contacts::Topics.list(id: contact_id, limit: 10, after: "cursor_123")

      expect(topics[:object]).to eql("list")
      expect(topics[:has_more]).to eql(true)
    end
  end

  describe "update contact topics" do
    it "should update topics by contact id" do
      resp = {
        id: "e169aa45-1ecf-4183-9955-b1499d5701d3"
      }

      params = {
        id: "e169aa45-1ecf-4183-9955-b1499d5701d3",
        topics: [
          {
            id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
            subscription: "opt_out"
          },
          {
            id: "07d84122-7224-4881-9c31-1c048e204602",
            subscription: "opt_in"
          }
        ]
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      result = Resend::Contacts::Topics.update(params)

      expect(result[:id]).to eql("e169aa45-1ecf-4183-9955-b1499d5701d3")
    end

    it "should update topics by contact email" do
      resp = {
        id: "e169aa45-1ecf-4183-9955-b1499d5701d3"
      }

      params = {
        email: "steve.wozniak@gmail.com",
        topics: [
          {
            id: "07d84122-7224-4881-9c31-1c048e204602",
            subscription: "opt_out"
          }
        ]
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      result = Resend::Contacts::Topics.update(params)

      expect(result[:id]).to eql("e169aa45-1ecf-4183-9955-b1499d5701d3")
    end

    it "should raise error when neither id nor email is provided" do
      params = {
        topics: [
          {
            id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
            subscription: "opt_out"
          }
        ]
      }

      expect {
        Resend::Contacts::Topics.update(params)
      }.to raise_error(ArgumentError, "Either :id or :email must be provided")
    end
  end
end
