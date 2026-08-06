# frozen_string_literal: true

RSpec.describe "OAuth Grants" do
  shared_examples "oauth grants api" do
    describe "list" do
      it "should list oauth grants" do
        resp = {
          "object": "list",
          "has_more": false,
          "data": [
            {
              "id": "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
              "client_id": "client_123",
              "scopes": ["emails:send"],
              "resource": nil,
              "created_at": "2023-04-21 01:31:02.671414+00",
              "revoked_at": nil,
              "revoked_reason": nil,
              "client": {
                "name": "My App",
                "logo_uri": "https://example.com/logo.png"
              }
            }
          ]
        }
        allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
        grants = Resend::OAuthGrants.list
        expect(grants[:data].length).to eql(1)
        expect(grants[:data].first[:id]).to eql("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")
        expect(grants[:has_more]).to be(false)
      end

      it "should build a paginated path" do
        expect(Resend::PaginationHelper).to receive(:build_paginated_path)
          .with("oauth/grants", { limit: 10 })
          .and_return("oauth/grants?limit=10")
        allow_any_instance_of(Resend::Request).to receive(:perform).and_return({})
        Resend::OAuthGrants.list({ limit: 10 })
      end
    end

    describe "revoke" do
      it "should revoke an oauth grant" do
        resp = {
          "object": "oauth_grant",
          "id": "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
          "revoked_at": "2023-04-22T10:00:00.000000+00:00",
          "revoked_reason": "user_requested"
        }
        allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
        grant = Resend::OAuthGrants.revoke("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")
        expect(grant[:id]).to eql("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")
        expect(grant[:revoked_reason]).to eql("user_requested")
      end
    end
  end

  context "static api_key" do
    before do
      Resend.configure do |config|
        config.api_key = "re_123"
      end
    end

    include_examples "oauth grants api"
  end

  context "dynamic api_key" do
    before do
      Resend.configure do |config|
        config.api_key = -> { "re_123" }
      end
    end

    include_examples "oauth grants api"
  end
end
