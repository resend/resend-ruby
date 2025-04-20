# frozen_string_literal: true

require "resend/request"
require "resend/client"

RSpec.describe Resend::Request do

  before do
    Resend.api_key = "re_123"
  end

  context '#perform' do
    context 'response is not json' do
      before do
        response = double(HTTParty::Response)
        html = "<html>not json</html>"
        allow(response).to receive(:body).and_return(html)
        allow(HTTParty).to receive(:send).and_return(response)
      end

      it 'should be rescuable' do
        req = described_class.new
        expect { req.perform }.to raise_error(Resend::Error::InternalServerError, /Resend API returned an unexpected response/)
      end
    end
  end

  context 'initialize' do
    it 'sets default headers' do
      req = described_class.new
      expect(req.instance_variable_get(:@headers)).to include(
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "User-Agent" => "resend-ruby:#{Resend::VERSION}",
        "Authorization" => "Bearer re_123"
      )
      expect(req.instance_variable_get(:@headers)).not_to include("Idempotency-Key")
    end

    it 'should set idempotency key' do
      req = described_class.new("path", {}, "POST", options: { idempotency_key: "123" })
      expect(req.instance_variable_get(:@headers)["Idempotency-Key"]).to eq("123")
    end

    it 'sets verb' do
      req = described_class.new("path", {}, "POST")
      expect(req.instance_variable_get(:@verb)).to eq("POST")
    end
  end

  context 'handle_error!' do

    it "Resend::Error::InvalidRequestError 400" do
      req = described_class.new
      resp = {
        :statusCode => 400,
        :message => "400"
      }
      expect { req.handle_error!(resp) }.to raise_error(Resend::Error::InvalidRequestError, /400/)
    end

    it "Resend::Error::InvalidRequestError 422" do
      req = described_class.new
      resp = {
        :statusCode => 422,
        :message => "422"
      }
      expect { req.handle_error!(resp) }.to raise_error(Resend::Error::InvalidRequestError, /422/)
    end

    it "Resend::Error::RateLimitExceededError 429" do
      req = described_class.new
      resp = {
        :statusCode => 429,
        :message => "429"
      }
      expect { req.handle_error!(resp) }.to raise_error(Resend::Error::RateLimitExceededError, /429/)
    end

    it "Resend::Error::InternalServerError 500" do
      req = described_class.new
      resp = {
        :statusCode => 500,
        :message => "500"
      }
      expect { req.handle_error!(resp) }.to raise_error(Resend::Error::InternalServerError, /500/)
    end

    it 'unkown error should return Resend::Error' do
      req = described_class.new
      resp = {
        :statusCode => 999,
        :message => "999"
      }
      expect { req.handle_error!(resp) }.to raise_error(Resend::Error, "999")
    end
  end
end
