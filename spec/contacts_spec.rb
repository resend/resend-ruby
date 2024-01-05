# frozen_string_literal: true

RSpec.describe "Contacts" do

  let(:audience_id) { "48c269ed-9873-4d60-bdd9-cd7e6fc0b9b8" }

  describe "create contact" do

    before do
      Resend.configure do |config|
        config.api_key = "re_123"
      end
    end

    it "should create a contact record" do
      resp = {
        "object": "contact",
        "id": "479e3145-dd38-476b-932c-529ceb705947"
      }

      params = {
        audience_id: audience_id,
        email: "steve@woz.com",
        first_name: "Steve",
        last_name: "Woz",
        unsubscribed: false,
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      contact = Resend::Contacts.create(params)
      expect(contact[:id]).to eql("479e3145-dd38-476b-932c-529ceb705947")
      expect(contact[:object]).to eql("contact")
    end
  end

  describe "get contact" do

    it "should retrieve a contact" do

      resp = {
        "object": "contact",
        "id": "e169aa45-1ecf-4183-9955-b1499d5701d3",
        "email": "steve.wozniak@gmail.com",
        "first_name": "Steve",
        "last_name": "Wozniak",
        "created_at": "2023-10-06T23:47:56.678Z",
        "unsubscribed": false
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(resp).to receive(:code).and_return(200)

      allow(HTTParty).to receive(:send).and_return(resp)

      contact = Resend::Contacts.get(audience_id, resp[:id])

      expect(contact[:object]).to eql "contact"
      expect(contact[:id]).to eql "e169aa45-1ecf-4183-9955-b1499d5701d3"
      expect(contact[:first_name]).to eql "Steve"
      expect(contact[:last_name]).to eql "Wozniak"
      expect(contact[:email]).to eql "steve.wozniak@gmail.com"
      expect(contact[:unsubscribed]).to be false
      expect(contact[:created_at]).to eql "2023-10-06T23:47:56.678Z"
    end
  end

  describe "list contacts" do

    it "should list contacts" do

      resp = {
        "object": "list",
        "data": [
          {
            "id": "e169aa45-1ecf-4183-9955-b1499d5701d3",
            "email": "steve.wozniak@gmail.com",
            "first_name": "Steve",
            "last_name": "Wozniak",
            "created_at": "2023-10-06T23:47:56.678Z",
            "unsubscribed": false
          }
        ]
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      contacts = Resend::Contacts.list(audience_id)
      expect(contacts[:object]).to eql "list"
      expect(contacts[:data].length).to eql 1
      expect(contacts[:data][0][:id]).to eql "e169aa45-1ecf-4183-9955-b1499d5701d3"
      expect(contacts[:data][0][:first_name]).to eql "Steve"
      expect(contacts[:data][0][:last_name]).to eql "Wozniak"
      expect(contacts[:data][0][:email]).to eql "steve.wozniak@gmail.com"
      expect(contacts[:data][0][:unsubscribed]).to be false
    end
  end

  describe "remove contact" do
    it "should remove contact by id" do

      resp = {
        "object": "contact",
        "id": "520784e2-887d-4c25-b53c-4ad46ad38100",
        "deleted": true
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(resp).to receive(:code).and_return(200)
      allow(HTTParty).to receive(:send).and_return(resp)

      deleted = Resend::Contacts.remove(audience_id, resp[:id])
      expect(deleted[:object]).to eql("contact")
      expect(deleted[:id]).to eql(resp[:id])
      expect(deleted[:deleted]).to be true
    end
  end

  describe "update contact" do

    before do
      Resend.configure do |config|
        config.api_key = "re_123"
      end
    end

    it "should update a contact record" do
      resp = {
        "object": "contact",
        "id": "479e3145-dd38-476b-932c-529ceb705947"
      }

      update_params = {
        audience_id: audience_id,
        id: "479e3145-dd38-476b-932c-529ceb705947",
        unsubscribed: false,
      }

      allow(resp).to receive(:code).and_return(200)
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      contact = Resend::Contacts.update(update_params)
      expect(contact[:id]).to eql("479e3145-dd38-476b-932c-529ceb705947")
      expect(contact[:object]).to eql("contact")
    end
  end
end
