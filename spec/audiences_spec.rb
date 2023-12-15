# frozen_string_literal: true

RSpec.describe "Audiences" do

  describe "create audience" do

    before do
      Resend.configure do |config|
        config.api_key = "re_123"
      end
    end

    it "should create an audience record" do
      resp = {
        "object": "audience",
        "id": "78261eea-8f8b-4381-83c6-79fa7120f1cf",
        "name": "Registered Users"
      }
      params = {
        "name": "Registered Users",
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      audience = Resend::Audiences.create(params)
      expect(audience[:id]).to eql("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      expect(audience[:name]).to eql("Registered Users")
      expect(audience[:object]).to eql("audience")
    end
  end

  describe "get audience" do
    it "should retrieve audience" do
      resp = {
        "object": "audience",
        "id": "78261eea-8f8b-4381-83c6-79fa7120f1cf",
        "name": "Registered Users",
        "created_at": "2023-10-06T22:59:55.977Z"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      audience = Resend::Audiences.get(resp[:id])

      expect(audience[:object]).to eql "audience"
      expect(audience[:id]).to eql "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      expect(audience[:name]).to eql "Registered Users"
      expect(audience[:created_at]).to eql "2023-10-06T22:59:55.977Z"
    end
  end

  describe "list audiences" do
    it "should list audiences" do
      resp = {
        "object": "list",
        "data": [
          {
            "id": "78261eea-8f8b-4381-83c6-79fa7120f1cf",
            "name": "Registered Users",
            "created_at": "2023-10-06T22:59:55.977Z"
          }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      audiences = Resend::Audiences.list
      expect(audiences[:object]).to eql "list"
      expect(audiences[:data].empty?).to be false
      expect(audiences[:data].length).to eql(1)
      expect(audiences[:data].first[:id]).to eql("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      expect(audiences[:data].first[:name]).to eql("Registered Users")
    end
  end

  describe "remove audience" do
    it "should remove audience by id" do

      resp = {
        "object": "audience",
        "id": "78261eea-8f8b-4381-83c6-79fa7120f1cf",
        "deleted": true
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      deleted = Resend::Audiences.remove("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      expect(deleted[:object]).to eql("audience")
      expect(deleted[:id]).to eql("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      expect(deleted[:deleted]).to be true
    end
  end
end
