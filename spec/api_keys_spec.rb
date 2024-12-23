# frozen_string_literal: true

RSpec.describe "API Keys" do
  context 'static api_key' do
    before do
      Resend.configure do |config|
        config.api_key = "re_123"
      end
    end

    describe "create" do

      it "should create api key" do
        resp = {
          "id": "dacf4072-4119-4d88-932f-6202748ac7c8",
          "token": "re_c1tpEyD8_NKFusih9vKVQknRAQfmFcWCv"
        }
        params = {
          "name": "production"
        }
        allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
        expect(Resend::ApiKeys.create(params)[:id]).to eql("dacf4072-4119-4d88-932f-6202748ac7c8")
      end

      it "should raise when permission is invalid" do
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
        expect { Resend::ApiKeys.create params }.to raise_error(Resend::Error::InvalidRequestError, /Access must be 'full_access' | 'sending_access'/)
      end
    end

    describe "list" do
      it "should list api keys" do
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
        expect(Resend::ApiKeys.list.length).to eql(1)
      end
    end

    describe "remove" do
      it "should remove api key" do
        allow_any_instance_of(Resend::Request).to receive(:perform).and_return("")
        expect { Resend::ApiKeys.remove }.not_to raise_error
      end
    end
  end

  context 'dynamic api_key' do
    before do
      Resend.configure do |config|
        config.api_key = -> { "re_123" }
      end
    end

    describe "create" do

      it "should create api key" do
        resp = {
          "id": "dacf4072-4119-4d88-932f-6202748ac7c8",
          "token": "re_c1tpEyD8_NKFusih9vKVQknRAQfmFcWCv"
        }
        params = {
          "name": "production"
        }
        allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
        expect(Resend::ApiKeys.create(params)[:id]).to eql("dacf4072-4119-4d88-932f-6202748ac7c8")
      end

      it "should raise when permission is invalid" do
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
        expect { Resend::ApiKeys.create params }.to raise_error(Resend::Error::InvalidRequestError, /Access must be 'full_access' | 'sending_access'/)
      end
    end

    describe "list" do
      it "should list api keys" do
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
        expect(Resend::ApiKeys.list.length).to eql(1)
      end
    end

    describe "remove" do
      it "should remove api key" do
        allow_any_instance_of(Resend::Request).to receive(:perform).and_return("")
        expect { Resend::ApiKeys.remove }.not_to raise_error
      end
    end
  end
end
