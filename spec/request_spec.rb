# frozen_string_literal: true

require "resend/request"
require "resend/client"

RSpec.describe Resend::Request do

  before do
    Resend.api_key = "re_123"
  end

  context "when response is not a json" do
    let(:response) { instance_double(HTTParty::Response, body: body) }
    let(:body) { '<html>not json</html>' }

    before do
      allow(HTTParty).to receive(:get).and_return(response)
      allow(response).to receive(:code).and_return(503)
    end

    it "should raise Resend::Error" do
      expect { Resend::Request.new("/", {}, "get").perform }.to raise_error(Resend::Error)
    end
  end

  it "Resend::Error::InvalidRequestError 400" do
    body = {
      "statusCode" => 400,
      "message" => "400"
    }
    response = instance_double(HTTParty::Response, body: body)

    allow(HTTParty).to receive(:get).and_return(response)
    allow(response).to receive(:code).and_return(400)
    allow(response).to receive(:parsed_response).and_return(body)

    expect { Resend::Request.new("/", {}, "get").perform }.to raise_error(Resend::Error::InvalidRequestError, /400/)
  end

  it "Resend::Error::InvalidRequestError 422" do
    body = {
      "statusCode" => 422,
      "message" => "422"
    }
    response = instance_double(HTTParty::Response, body: body)

    allow(HTTParty).to receive(:get).and_return(response)
    allow(response).to receive(:code).and_return(422)
    allow(response).to receive(:parsed_response).and_return(body)

    expect { Resend::Request.new("/", {}, "get").perform }.to raise_error(Resend::Error::InvalidRequestError, /422/)
  end

  it "Resend::Error::RateLimitExceededError 429" do
    body = {
      "statusCode" => 429,
      "message" => "429"
    }
    response = instance_double(HTTParty::Response, body: body)

    allow(HTTParty).to receive(:get).and_return(response)
    allow(response).to receive(:code).and_return(429)
    allow(response).to receive(:parsed_response).and_return(body)

    expect { Resend::Request.new("/", {}, "get").perform }.to raise_error(Resend::Error::RateLimitExceededError, /429/)
  end

  it "Resend::Error::InternalServerError 500" do
    body = {
      "statusCode" => 500,
      "message" => "500"
    }
    response = instance_double(HTTParty::Response, body: body)

    allow(HTTParty).to receive(:get).and_return(response)
    allow(response).to receive(:code).and_return(500)
    allow(response).to receive(:parsed_response).and_return(body)

    expect { Resend::Request.new("/", {}, "get").perform }.to raise_error(Resend::Error::InternalServerError, /500/)
  end
end
