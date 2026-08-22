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
        "created_at": "2023-04-03 22:13:42.674981+00",
        "subject": "Hello World",
        "html": "Congrats on sending your <strong>first email</strong>!",
        "text": nil,
        "bcc": [nil],
        "cc": [nil],
        "reply_to": [nil],
        "last_event": "delivered",
        "message_id": "<111-222-333@email.example.com>"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)
      email = Resend::Emails.get(resp[:id])
      expect(email[:subject]).to eql "Hello World"
      expect(email[:id]).to eql "4ef9a417-02e9-4d39-ad75-9611e0fcc33c"
      expect(email[:message_id]).to eql "<111-222-333@email.example.com>"
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

    it "shares an email with the default expires_in" do
      email_id = "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      resp = {
        "object": "email",
        "id": email_id,
        "url": "https://resend.com/share/#{email_id}"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      result = Resend::Emails.share(email_id)

      expect(HTTParty).to have_received(:send).with(
        :post,
        "#{Resend::Request::BASE_URL}emails/#{email_id}/share",
        hash_not_including(:body)
      )
      expect(result[:id]).to eql email_id
      expect(result[:url]).to eql "https://resend.com/share/#{email_id}"
    end

    it "shares an email with a custom expires_in" do
      email_id = "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      resp = {
        "object": "email",
        "id": email_id,
        "url": "https://resend.com/share/#{email_id}"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      result = Resend::Emails.share(email_id, expires_in: "10m")

      expect(HTTParty).to have_received(:send).with(
        :post,
        "#{Resend::Request::BASE_URL}emails/#{email_id}/share",
        hash_including(body: { expires_in: "10m" }.to_json)
      )
      expect(result[:url]).to eql "https://resend.com/share/#{email_id}"
    end

    it "raises when expires_in is malformed or exceeds 48 hours" do
      resp = {
        "statusCode" => 422,
        "name" => "validation_error",
        "message" => "expires_in must not exceed 48h"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      expect { Resend::Emails.share("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794", expires_in: "72h") }
        .to raise_error(Resend::Error::InvalidRequestError, /expires_in must not exceed 48h/)
    end

    it "raises not found when the email id does not exist" do
      resp = {
        "statusCode" => 404,
        "name" => "not_found",
        "message" => "Email not found"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      expect { Resend::Emails.share("does-not-exist") }
        .to raise_error(Resend::Error::NotFoundError, /Email not found/)
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
            "created_at" => "2023-04-03 22:13:42.674981+00",
            "subject" => "Hello World",
            "last_event" => "delivered",
            "message_id" => "<111-222-333@email.example.com>"
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

    it "retrieves metrics without parameters" do
      resp = {
        "object" => "metrics",
        "start_date" => "2026-07-01T00:00:00.000Z",
        "end_date" => "2026-07-08T00:00:00.000Z",
        "metrics" => ["delivered"],
        "dimensions" => [],
        "granularity" => "daily",
        "totals" => { "delivered" => 100 }
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      result = Resend::Emails.metrics

      expect(HTTParty).to have_received(:send).with(:get, "#{Resend::Request::BASE_URL}emails/metrics", anything)
      expect(result[:object]).to eql("metrics")
      expect(result[:totals]).to eql({ "delivered" => 100 })
    end

    it "omits empty dimensions and start_date instead of sending them blank" do
      resp = {
        "object" => "metrics",
        "dimensions" => [],
        "totals" => { "delivered" => 100 }
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Emails.metrics(dimensions: [], start_date: "")

      expect(HTTParty).to have_received(:send).with(:get, "#{Resend::Request::BASE_URL}emails/metrics", anything)
    end

    it "retrieves metrics with the period dimension" do
      resp = {
        "object" => "metrics",
        "dimensions" => ["period"],
        "totals" => { "delivered" => 100 },
        "data" => [{ "period" => "2026-07-01", "delivered" => 10 }]
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      result = Resend::Emails.metrics(dimensions: ["period"])

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/metrics",
        hash_including(query: { dimensions: "period" })
      )
      expect(result[:data].first["period"]).to eql("2026-07-01")
    end

    it "retrieves metrics with the domain dimension" do
      resp = {
        "object" => "metrics",
        "dimensions" => ["domain"],
        "totals" => { "delivered" => 100 },
        "data" => [{ "domain_id" => "d91cd9bd-f5ab-4bbe-89c8-c890a4caced4", "domain_name" => "example.com", "delivered" => 10 }]
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      result = Resend::Emails.metrics(dimensions: ["domain"])

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/metrics",
        hash_including(query: { dimensions: "domain" })
      )
      expect(result[:data].first["domain_name"]).to eql("example.com")
    end

    it "retrieves metrics with the email dimension" do
      resp = {
        "object" => "metrics",
        "dimensions" => ["email"],
        "totals" => { "delivered" => 100 },
        "data" => [{ "email_id" => "4ef9a417-02e9-4d39-ad75-9611e0fcc33c", "delivered" => 1 }]
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      result = Resend::Emails.metrics(dimensions: ["email"])

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/metrics",
        hash_including(query: { dimensions: "email" })
      )
      expect(result[:data].first["email_id"]).to eql("4ef9a417-02e9-4d39-ad75-9611e0fcc33c")
    end

    it "retrieves metrics with the broadcast dimension" do
      resp = {
        "object" => "metrics",
        "dimensions" => ["broadcast"],
        "totals" => { "delivered" => 100 },
        "data" => [{ "broadcast_id" => "b6d24b8e-af0b-4c3c-be0c-359bf9d251d2", "broadcast_name" => "July Newsletter", "delivered" => 10 }]
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      result = Resend::Emails.metrics(dimensions: ["broadcast"])

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/metrics",
        hash_including(query: { dimensions: "broadcast" })
      )
      expect(result[:data].first["broadcast_name"]).to eql("July Newsletter")
    end

    it "retrieves metrics with multiple dimensions combined" do
      resp = {
        "object" => "metrics",
        "dimensions" => ["period", "broadcast"],
        "totals" => { "delivered" => 100 }
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Emails.metrics(dimensions: ["period", "broadcast"])

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/metrics",
        hash_including(query: { dimensions: "period,broadcast" })
      )
    end

    it "raises when combining the email and broadcast dimensions" do
      expect { Resend::Emails.metrics(dimensions: %w[email broadcast]) }
        .to raise_error(ArgumentError, /broadcast.*email/)
    end

    it "raises when combining the broadcast dimension with email_id" do
      expect { Resend::Emails.metrics(dimensions: ["broadcast"], email_id: ["e1"]) }
        .to raise_error(ArgumentError, /broadcast.*email/)
    end

    it "raises when combining the email dimension with broadcast_id" do
      expect { Resend::Emails.metrics(dimensions: ["email"], broadcast_id: ["b1"]) }
        .to raise_error(ArgumentError, /broadcast.*email/)
    end

    it "raises when combining email_id and broadcast_id filters" do
      expect { Resend::Emails.metrics(email_id: ["e1"], broadcast_id: ["b1"]) }
        .to raise_error(ArgumentError, /broadcast.*email/)
    end

    it "retrieves metrics filtered by a single domain_id" do
      resp = { "object" => "metrics", "totals" => {} }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Emails.metrics(domain_id: ["d91cd9bd-f5ab-4bbe-89c8-c890a4caced4"])

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/metrics",
        hash_including(query: { domain_id: "d91cd9bd-f5ab-4bbe-89c8-c890a4caced4" })
      )
    end

    it "retrieves metrics filtered by multiple domain_ids" do
      resp = { "object" => "metrics", "totals" => {} }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Emails.metrics(domain_id: ["domain_1", "domain_2"])

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/metrics",
        hash_including(query: { domain_id: "domain_1,domain_2" })
      )
    end

    it "retrieves metrics filtered by a single email_id" do
      resp = { "object" => "metrics", "totals" => {} }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Emails.metrics(email_id: ["4ef9a417-02e9-4d39-ad75-9611e0fcc33c"])

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/metrics",
        hash_including(query: { email_id: "4ef9a417-02e9-4d39-ad75-9611e0fcc33c" })
      )
    end

    it "retrieves metrics filtered by multiple email_ids" do
      resp = { "object" => "metrics", "totals" => {} }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Emails.metrics(email_id: ["email_1", "email_2"])

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/metrics",
        hash_including(query: { email_id: "email_1,email_2" })
      )
    end

    it "retrieves metrics filtered by a single broadcast_id" do
      resp = { "object" => "metrics", "totals" => {} }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Emails.metrics(broadcast_id: ["b6d24b8e-af0b-4c3c-be0c-359bf9d251d2"])

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/metrics",
        hash_including(query: { broadcast_id: "b6d24b8e-af0b-4c3c-be0c-359bf9d251d2" })
      )
    end

    it "retrieves metrics filtered by multiple broadcast_ids" do
      resp = { "object" => "metrics", "totals" => {} }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Emails.metrics(broadcast_id: ["broadcast_1", "broadcast_2"])

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/metrics",
        hash_including(query: { broadcast_id: "broadcast_1,broadcast_2" })
      )
    end

    it "passes metrics, granularity and timezone through to the query" do
      resp = { "object" => "metrics", "totals" => {} }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Emails.metrics(
        metrics: ["delivered", "opened"],
        granularity: "hourly",
        timezone: "America/New_York"
      )

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/metrics",
        hash_including(
          query: {
            metrics: "delivered,opened",
            granularity: "hourly",
            timezone: "America/New_York"
          }
        )
      )
    end

    it "passes start_date and end_date through to the query" do
      resp = { "object" => "metrics", "totals" => {} }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Resend::Emails.metrics(
        start_date: "2026-07-01",
        end_date: "2026-07-08T00:00:00.000Z"
      )

      expect(HTTParty).to have_received(:send).with(
        :get,
        "#{Resend::Request::BASE_URL}emails/metrics",
        hash_including(
          query: {
            start_date: "2026-07-01",
            end_date: "2026-07-08T00:00:00.000Z"
          }
        )
      )
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

    it "exposes response headers" do
      resp_data = {id: "872d1f17-0f08-424c-a18c-d425324acab6"}
      resp_headers = {"content-type" => "application/json", "x-ratelimit-remaining" => "50"}
      mock_response = Resend::Response.new(resp_data, resp_headers)

      params = {
        "from": "from@e.io",
        "to": ["email1@email.com"],
        "text": "test",
        "subject": "test"
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(mock_response)

      result = Resend::Emails.send(params)

      # Backwards compatible hash access
      expect(result[:id]).to eql("872d1f17-0f08-424c-a18c-d425324acab6")

      # New headers functionality
      expect(result.headers).to be_a(Hash)
      expect(result.headers["content-type"]).to eq("application/json")
      expect(result.headers["x-ratelimit-remaining"]).to eq("50")
    end

    it "maintains backwards compatibility with hash operations" do
      resp_data = {id: "872d1f17-0f08-424c-a18c-d425324acab6", status: "sent"}
      resp_headers = {"content-type" => "application/json"}
      mock_response = Resend::Response.new(resp_data, resp_headers)

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(mock_response)

      result = Resend::Emails.send({ from: "test@example.com", to: ["user@example.com"] })

      # All hash-like operations should still work
      expect(result[:id]).to eq("872d1f17-0f08-424c-a18c-d425324acab6")
      expect(result[:status]).to eq("sent")
      expect(result.dig(:id)).to eq("872d1f17-0f08-424c-a18c-d425324acab6")
      expect(result.keys).to include(:id, :status)
      expect(result.values).to include("872d1f17-0f08-424c-a18c-d425324acab6", "sent")
    end
  end
end
