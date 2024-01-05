# frozen_string_literal: true

RSpec.describe "Domains" do

  describe "create domain" do

    before do
      Resend.configure do |config|
        config.api_key = "re_123"
      end
    end

    it "should create domain record" do
      resp = {
        "id": "4dd369bc-aa82-4ff3-97de-514ae3000ee0",
        "name": "example.com",
        "createdAt": "2023-03-28T17:12:02.059593+00:00",
        "status": "not_started",
        "records": [
          {
            "record": "SPF",
            "name": "bounces",
            "type": "MX",
            "ttl": "Auto",
            "status": "not_started",
            "value": "feedback-smtp.us-east-1.amazonses.com",
            "priority": 10
          },
          {
            "record": "SPF",
            "name": "bounces",
            "value": "\"v=spf1 include:amazonses.com ~all\"",
            "type": "TXT",
            "ttl": "Auto",
            "status": "not_started"
          },
          {
            "record": "DKIM",
            "name": "nhapbbryle57yxg3fbjytyodgbt2kyyg._domainkey",
            "value": "nhapbbryle57yxg3fbjytyodgbt2kyyg.dkim.amazonses.com.",
            "type": "CNAME",
            "status": "not_started",
            "ttl": "Auto"
          },
          {
            "record": "DKIM",
            "name": "xbakwbe5fcscrhzshpap6kbxesf6pfgn._domainkey",
            "value": "xbakwbe5fcscrhzshpap6kbxesf6pfgn.dkim.amazonses.com.",
            "type": "CNAME",
            "status": "not_started",
            "ttl": "Auto"
          },
          {
            "record": "DKIM",
            "name": "txrcreso3dqbvcve45tqyosxwaegvhgn._domainkey",
            "value": "txrcreso3dqbvcve45tqyosxwaegvhgn.dkim.amazonses.com.",
            "type": "CNAME",
            "status": "not_started",
            "ttl": "Auto"
          }
        ],
        "region": "us-east-1",
        "dnsProvider": "Unidentified"
      }
      params = {
        "name": "example.com",
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(Resend::Domains.create(params)[:id]).to eql("4dd369bc-aa82-4ff3-97de-514ae3000ee0")
    end

    it "should raise when domain is already registered" do
      resp = {
        "name"=>"validation_error",
        "message"=>"The name domain has been registered already.",
        "statusCode"=>400
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(resp).to receive(:code).and_return(422)
      allow(resp).to receive(:parsed_response).and_return(resp)

      params = {
        "name": "example.com",
      }
      allow(HTTParty).to receive(:send).and_return(resp)
      expect { Resend::Domains.create params }.to raise_error(Resend::Error::InvalidRequestError, /The name domain has been registered already./)
    end
  end

  describe "get domain" do
    it "should retrieve domain" do
      resp = {
        "object": "domain",
        "id": "d91cd9bd-1176-453e-8fc1-35364d380206",
        "name": "example.com",
        "status": "not_started",
        "created_at": "2023-04-26T20:21:26.347412+00:00",
        "region": "us-east-1"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(resp).to receive(:code).and_return(200)

      allow(HTTParty).to receive(:send).and_return(resp)

      email = Resend::Domains.get(resp[:id])

      expect(email[:object]).to eql "domain"
      expect(email[:id]).to eql "d91cd9bd-1176-453e-8fc1-35364d380206"
      expect(email[:name]).to eql "example.com"
      expect(email[:status]).to eql "not_started"
      expect(email[:created_at]).to eql "2023-04-26T20:21:26.347412+00:00"
      expect(email[:region]).to eql "us-east-1"
    end
  end

  describe "list domains" do
    it "should list domains" do
      resp = {
        "data": [
          {
            "id": "d91cd9bd-1176-453e-8fc1-35364d380206",
            "name": "example.com",
            "status": "not_started",
            "created_at": "2023-04-26T20:21:26.347412+00:00",
            "region": "us-east-1"
          }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(Resend::Domains.list[:data].empty?).to be false
      expect(Resend::Domains.list[:data].length).to eql(1)
    end
  end

  describe "remove domain" do
    it "should remove domain by domain id" do
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return("")
      expect { Resend::Domains.remove }.not_to raise_error
    end
  end

  describe "verify domain" do
    it "should verify domain by domain id" do
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return("")
      expect { Resend::Domains.verify }.not_to raise_error
    end
  end
end
