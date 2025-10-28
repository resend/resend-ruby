# frozen_string_literal: true

RSpec.describe "Emails" do

  describe "send_email" do

    before do
      Resend.api_key = "re_123"
    end

    it "sends email" do
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

    it "updates email" do
      resp = {"id"=>"872d1f17-0f08-424c-a18c-d425324acab6", "object": "email"}
      params = {
        "id": "872d1f17-0f08-424c-a18c-d425324acab6",
        "scheduled_at": "2024-11-05T11:52:01.858Z"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(Resend::Emails.update(params)[:id]).to eql(resp[:id])
    end

    it "retrieves email" do
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

    it "cancels email" do
      resp = {
        "object": "email",
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      email = Resend::Emails.cancel(resp[:id])
      expect(email[:id]).to eql "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
    end

    it "raises when to is missing" do
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

    it "raises when from is missing" do
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

    it "lists emails without parameters" do
      resp = {
        "object" => "list",
        "has_more" => false,
        "data" => [
          {
            "id" => "4ef9a417-02e9-4d39-ad75-9611e0fcc33c",
            "to" => ["james@bond.com"],
            "from" => "onboarding@resend.dev",
            "created_at" => "2023-04-03T22:13:42.674981+00:00",
            "subject" => "Hello World",
            "last_event" => "delivered"
          }
        ]
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      result = Resend::Emails.list
      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to eql(false)
      expect(result[:data].length).to eql(1)
    end

    it "lists emails with limit parameter" do
      resp = {
        "object" => "list",
        "has_more" => true,
        "data" => []
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      result = Resend::Emails.list(limit: 50)

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails",
        hash_including(
          query: { limit: 50 }
        )
      )
      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to eql(true)
    end

    it "lists emails with pagination parameters" do
      resp = {
        "object" => "list",
        "has_more" => false,
        "data" => []
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      result = Resend::Emails.list(limit: 20, after: "cursor_123", before: "cursor_456")

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails",
        hash_including(
          query: { limit: 20, after: "cursor_123", before: "cursor_456" }
        )
      )
      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to eql(false)
    end

    it "sends email with template without variables" do
      resp = {"id"=>"49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"}
      params = {
        from: "onboarding@resend.dev",
        to: ["delivered@resend.dev"],
        template: {
          id: "d91cd9bd-f5ab-4bbe-89c8-c890a4caced4"
        }
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(Resend::Emails.send(params)[:id]).to eql(resp[:id])
    end

    it "sends email with template with variables" do
      resp = {"id"=>"49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"}
      params = {
        from: "onboarding@resend.dev",
        to: ["delivered@resend.dev"],
        template: {
          id: "d91cd9bd-f5ab-4bbe-89c8-c890a4caced4",
          variables: {
            name: "Alice",
            age: 30
          }
        }
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(Resend::Emails.send(params)[:id]).to eql(resp[:id])
    end
  end
end
