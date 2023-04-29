# frozen_string_literal: true

RSpec.describe "Emails" do

  describe "send_email" do
    it "should send email" do
      c = Resend::Client.new "re_123"
      resp = {"id"=>"872d1f17-0f08-424c-a18c-d425324acab6"}
      params = {
        "from": "from@e.io",
        "to": ["email1@email.com"],
        "text": "test",
        "subject": "test",
        "tags": {
          "country": "br"
        }
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(c.send_email(params)[:id]).to eql(resp[:id])
    end

    it "should raise when to is missing" do
      c = Resend::Client.new "re_123"
      resp = {
        "statusCode"=>422,
        "name"=>"missing_required_field",
        "message"=>"Missing `to` field"
      }
      allow(resp).to receive(:body).and_return(resp)
      params = {
        "from": "from@e.io",
        "text": "test",
        "subject": "test",
        "tags": {
          "country": "br"
        }
      }
      allow(HTTParty).to receive(:send).and_return(resp)
      expect { c.send_email params }.to raise_error(Resend::Error::InvalidRequestError, /Missing `to` field/)
    end

    it "should raise when from is missing" do
      c = Resend::Client.new "re_123"
      resp = {
        "statusCode"=>422,
        "name"=>"missing_required_field",
        "message"=>"Missing `from` field"
      }
      allow(resp).to receive(:body).and_return(resp)
      params = {
        "to": ["from@e.io"],
        "text": "test",
        "subject": "test",
        "tags": {
          "country": "br"
        }
      }
      allow(HTTParty).to receive(:send).and_return(resp)
      expect { c.send_email params }.to raise_error(Resend::Error::InvalidRequestError, /Missing `from` field/)
    end
  end
end
