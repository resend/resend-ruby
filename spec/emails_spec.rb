# frozen_string_literal: true

RSpec.describe "Emails" do

  describe "send_email" do

    before do
      Resend.api_key = "re_123"
    end

    it "should send email" do
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
      expect(Resend::Emails.send(params)[:id]).to eql(resp[:id])
    end

    it "should update email" do
      resp = {"id"=>"872d1f17-0f08-424c-a18c-d425324acab6", "object": "email"}
      params = {
        "id": "872d1f17-0f08-424c-a18c-d425324acab6",
        "scheduled_at": "2024-11-05T11:52:01.858Z"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(Resend::Emails.update(params)[:id]).to eql(resp[:id])
    end

    it "should retrieve email" do
      resp = {
        "object": "email",
        "id": "4ef9a417-02e9-4d39-ad75-9611e0fcc33c",
        "to": ["james@bond.com"],
        "from": "onboarding@resend.dev",
        "created_at": "2023-04-03T22:13:42.674981+00:00",
        "subject": "Hello World",
        "html": "Congrats on sending your <strong>first email</strong>!",
        "text": nil,
        "bcc": [nil],
        "cc": [nil],
        "reply_to": [nil],
        "last_event": "delivered"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)
      email = Resend::Emails.get(resp[:id])
      expect(email[:subject]).to eql "Hello World"
      expect(email[:id]).to eql "4ef9a417-02e9-4d39-ad75-9611e0fcc33c"
    end

    it "should cancel email" do
      resp = {
        "object": "email",
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      email = Resend::Emails.cancel(resp[:id])
      expect(email[:id]).to eql "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
    end

    it "should raise when to is missing" do
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
      expect { Resend::Emails.send params }.to raise_error(Resend::Error::InvalidRequestError, /Missing `to` field/)
    end

    it "should raise when from is missing" do
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
      expect { Resend::Emails.send params }.to raise_error(Resend::Error::InvalidRequestError, /Missing `from` field/)
    end

    it "does not send the Idempotency-Key header when :idempotency_key is not provided" do
      resp = {
        "id"=>"872d1f17-0f08-424c-a18c-d425324acab6", "object": "email"
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Emails.send({ from: "me" })

      expect(HTTParty).to have_received(:send).with(
        :post,
        "#{Resend::Request::BASE_URL}emails",
        {
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json",
            "Authorization" => "Bearer re_123",
            "User-Agent" => "resend-ruby:#{Resend::VERSION}",
          },
          body: { from: "me" }.to_json
        }
      )
    end

    it "does not send the Idempotency-Key header when :idempotency_key is nil" do
      resp = {
        "id"=>"872d1f17-0f08-424c-a18c-d425324acab6", "object": "email"
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Emails.send({ from: "me" }, options: { idempotency_key: nil })

      expect(HTTParty).to have_received(:send).with(
        :post,
        "#{Resend::Request::BASE_URL}emails",
        {
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json",
            "Authorization" => "Bearer re_123",
            "User-Agent" => "resend-ruby:#{Resend::VERSION}",
          },
          body: { from: "me" }.to_json
        }
      )
    end

    it "does not send the Idempotency-Key header when :idempotency_key is an empty string" do
      resp = {
        "id"=>"872d1f17-0f08-424c-a18c-d425324acab6", "object": "email"
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Emails.send({ from: "me" }, options: { idempotency_key: "" })

      expect(HTTParty).to have_received(:send).with(
        :post,
        "#{Resend::Request::BASE_URL}emails",
        {
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json",
            "Authorization" => "Bearer re_123",
            "User-Agent" => "resend-ruby:#{Resend::VERSION}",
          },
          body: { from: "me" }.to_json
        }
      )
    end

    it "does send the Idempotency-Key header when :idempotency_key is provided" do
      resp = {
        "id"=>"872d1f17-0f08-424c-a18c-d425324acab6", "object": "email"
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Emails.send({ from: "me" }, options: { idempotency_key: "123" })

      expect(HTTParty).to have_received(:send).with(
        :post,
        "#{Resend::Request::BASE_URL}emails",
        {
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json",
            "Authorization" => "Bearer re_123",
            "User-Agent" => "resend-ruby:#{Resend::VERSION}",
            "Idempotency-Key" => "123"
          },
          body: { from: "me" }.to_json
        }
      )
    end
  end
end
