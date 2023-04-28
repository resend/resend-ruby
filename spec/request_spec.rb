# frozen_string_literal: true

require "resend/request"
require "resend/client"

RSpec.describe Resend::Request do

  before do
    @client = Resend::Client.new "re_123"
  end

  it "Resend::Error::InvalidRequestError 400" do
    req = described_class.new(@client)
    resp = {
      :statusCode => 400,
      :message => "400"
    }
    expect { req.handle_error!(resp) }.to raise_error(Resend::Error::InvalidRequestError, /400/)
  end

  it "Resend::Error::InvalidRequestError 422" do
    req = described_class.new(@client)
    resp = {
      :statusCode => 422,
      :message => "422"
    }
    expect { req.handle_error!(resp) }.to raise_error(Resend::Error::InvalidRequestError, /422/)
  end

  it "Resend::Error::InternalServerErro 500" do
    req = described_class.new(@client)
    resp = {
      :statusCode => 500,
      :message => "500"
    }
    expect { req.handle_error!(resp) }.to raise_error(Resend::Error::InternalServerError, /500/)
  end
end
