# frozen_string_literal: true

RSpec.describe "Batch" do
  describe "#send" do

    before do
      Resend.api_key = "re_123"
    end

    it "should send batch email" do
      resp = {
        "data": [
          {
            "id": "ae2014de-c168-4c61-8267-70d2662a1ce1"
          },
          {
            "id": "faccb7a5-8a28-4e9a-ac64-8da1cc3bc1cb"
          }
        ]
      }

      params = [
        {
          "from": "from@e.io",
          "to": ["email1@email.com"],
          "text": "testing",
          "subject": "Hey",
        },
        {
          "from": "from@e.io",
          "to": ["email2@email.com"],
          "text": "testing",
          "subject": "Hello",
        },
      ]
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      emails = Resend::Batch.send(params)
      expect(emails[:data].length).to eq 2
    end

    it "does not send the Idempotency-Key header when :idempotency_key is not provided" do
      resp = {
        "id"=>"872d1f17-0f08-424c-a18c-d425324acab6", "object": "email"
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Batch.send([{ from: "me" }], options: {})

      expect(HTTParty).to have_received(:send).with(
        :post,
        "#{Resend::Request::BASE_URL}emails/batch",
        {
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json",
            "Authorization" => "Bearer re_123",
            "User-Agent" => "resend-ruby:#{Resend::VERSION}",
          },
          body: [{ from: "me" }].to_json
        }
      )
    end

    it "does not send the Idempotency-Key header when :idempotency_key is nil" do
      resp = {
        "id"=>"872d1f17-0f08-424c-a18c-d425324acab6", "object": "email"
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Batch.send([{ from: "me" }], options: { idempotency_key: nil })

      expect(HTTParty).to have_received(:send).with(
        :post,
        "#{Resend::Request::BASE_URL}emails/batch",
        {
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json",
            "Authorization" => "Bearer re_123",
            "User-Agent" => "resend-ruby:#{Resend::VERSION}",
          },
          body: [{ from: "me" }].to_json
        }
      )
    end

    it "does not send the Idempotency-Key header when :idempotency_key is an empty string" do
      resp = {
        "id"=>"872d1f17-0f08-424c-a18c-d425324acab6", "object": "email"
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Batch.send([{ from: "me" }], options: { idempotency_key: "" })

      expect(HTTParty).to have_received(:send).with(
        :post,
        "#{Resend::Request::BASE_URL}emails/batch",
        {
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json",
            "Authorization" => "Bearer re_123",
            "User-Agent" => "resend-ruby:#{Resend::VERSION}",
          },
          body: [{ from: "me" }].to_json
        }
      )
    end

    it "does send the Idempotency-Key header when :idempotency_key is provided" do
      resp = {
        "id"=>"872d1f17-0f08-424c-a18c-d425324acab6", "object": "email"
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Batch.send([{ from: "me" }], options: { idempotency_key: "123" })

      expect(HTTParty).to have_received(:send).with(
        :post,
        "#{Resend::Request::BASE_URL}emails/batch",
        {
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json",
            "Authorization" => "Bearer re_123",
            "User-Agent" => "resend-ruby:#{Resend::VERSION}",
            "Idempotency-Key" => "123"
          },
          body: [{ from: "me" }].to_json
        }
      )
    end
  end
end
