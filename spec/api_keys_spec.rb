# frozen_string_literal: true

RSpec.describe "API Keys" do

  describe "create_api_key" do
    it "should create api key" do
      c = Resend::Client.new "re_123"
      resp = {
        "id": "dacf4072-4119-4d88-932f-6202748ac7c8",
        "token": "re_c1tpEyD8_NKFusih9vKVQknRAQfmFcWCv"
      }
      params = {
        "name": "production"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(c.create_api_key(params)[:id]).to eql("dacf4072-4119-4d88-932f-6202748ac7c8")
    end

    it "should raise when permission is invalid" do
      c = Resend::Client.new "re_123"
      resp = {
        "statusCode" => 422,
        "name" => "invalid_permission",
        "message" => "Access must be 'full_access' | 'sending_access'"
      }
      allow(resp).to receive(:body).and_return(resp)
      params = {
        "name": "production",
        "permission": "invalid"
      }
      allow(HTTParty).to receive(:send).and_return(resp)
      expect { c.create_api_key params }.to raise_error(Resend::Error::InvalidRequestError, /Access must be 'full_access' | 'sending_access'/)
    end
  end

  describe "list_api_keys" do
    it "should list api keys" do
      c = Resend::Client.new "re_123"
      resp = {
        "data": [
          {
            "id":"6e3c3d83-05dc-4b51-acfc-fe8972738bd0",
            "name":"test1",
            "created_at":"2023-04-21T01:31:02.671414+00:00"
          }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(c.list_api_keys.length).to eql(1)
    end
  end

  describe "delete_api_key" do
    it "should delete api key" do
      c = Resend::Client.new "re_123"
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return("")
      expect { c.delete_api_key }.not_to raise_error
    end
  end
end
