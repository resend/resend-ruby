# frozen_string_literal: true

RSpec.describe "Events" do
  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  let(:event_id) { "evt_abc123" }
  let(:event_name) { "user.signed_up" }

  describe "create" do
    it "should create an event without schema" do
      resp = {
        object: "event",
        id: event_id,
        name: event_name,
        schema: nil,
        created_at: "2024-01-01T00:00:00.000Z",
        updated_at: "2024-01-01T00:00:00.000Z"
      }
      params = { name: event_name }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Events.create(params)
      expect(result[:id]).to eql(event_id)
      expect(result[:name]).to eql(event_name)
      expect(result[:schema]).to be_nil
    end

    it "should create an event with schema" do
      schema = { "plan" => "string", "trial_days" => "number", "is_enterprise" => "boolean" }
      resp = {
        object: "event",
        id: event_id,
        name: event_name,
        schema: schema,
        created_at: "2024-01-01T00:00:00.000Z",
        updated_at: "2024-01-01T00:00:00.000Z"
      }
      params = { name: event_name, schema: schema }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Events.create(params)
      expect(result[:id]).to eql(event_id)
      expect(result[:schema]).to eql(schema)
    end

    it "should use POST /events" do
      params = { name: event_name }
      req = double("req", perform: { id: event_id })
      expect(Resend::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("events")
        expect(verb).to eql("post")
        req
      end
      Resend::Events.create(params)
    end
  end

  describe "get" do
    it "should retrieve an event by ID" do
      resp = {
        object: "event",
        id: event_id,
        name: event_name,
        schema: nil,
        created_at: "2024-01-01T00:00:00.000Z",
        updated_at: "2024-01-01T00:00:00.000Z"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Events.get(event_id)
      expect(result[:id]).to eql(event_id)
      expect(result[:object]).to eql("event")
    end

    it "should retrieve an event by name" do
      resp = {
        object: "event",
        id: event_id,
        name: event_name,
        schema: nil,
        created_at: "2024-01-01T00:00:00.000Z",
        updated_at: "2024-01-01T00:00:00.000Z"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Events.get(event_name)
      expect(result[:name]).to eql(event_name)
    end

    it "should use GET /events/:identifier" do
      req = double("req", perform: { id: event_id })
      expect(Resend::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("events/#{CGI.escape(event_id)}")
        expect(verb).to eql("get")
        req
      end
      Resend::Events.get(event_id)
    end

    it "should URL-encode the identifier when it is an event name" do
      req = double("req", perform: { name: event_name })
      expect(Resend::Request).to receive(:new).once do |path, _body, _verb|
        expect(path).to eql("events/#{CGI.escape(event_name)}")
        req
      end
      Resend::Events.get(event_name)
    end
  end

  describe "update" do
    it "should update an event schema" do
      new_schema = { "plan" => "string", "upgraded_at" => "date" }
      resp = {
        object: "event",
        id: event_id,
        name: event_name,
        schema: new_schema,
        created_at: "2024-01-01T00:00:00.000Z",
        updated_at: "2024-01-02T00:00:00.000Z"
      }
      params = { identifier: event_id, schema: new_schema }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Events.update(params)
      expect(result[:schema]).to eql(new_schema)
    end

    it "should use PATCH /events/:identifier" do
      new_schema = { "plan" => "string" }
      params = { identifier: event_id, schema: new_schema }
      req = double("req", perform: { id: event_id })
      expect(Resend::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("events/#{CGI.escape(event_id)}")
        expect(verb).to eql("patch")
        req
      end
      Resend::Events.update(params)
    end

    it "should NOT include identifier in the request body" do
      params = { identifier: event_id, schema: { "plan" => "string" } }
      req = double("req", perform: { id: event_id })
      expect(Resend::Request).to receive(:new).once do |_path, body, _verb|
        expect(body).not_to have_key(:identifier)
        expect(body[:schema]).to eql({ "plan" => "string" })
        req
      end
      Resend::Events.update(params)
    end

    it "should accept a name-based identifier" do
      params = { identifier: event_name, schema: nil }
      req = double("req", perform: { id: event_id })
      expect(Resend::Request).to receive(:new).once do |path, _body, _verb|
        expect(path).to eql("events/#{CGI.escape(event_name)}")
        req
      end
      Resend::Events.update(params)
    end
  end

  describe "remove" do
    it "should delete an event by ID" do
      resp = { object: "event", id: event_id, deleted: true }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Events.remove(event_id)
      expect(result[:id]).to eql(event_id)
      expect(result[:deleted]).to eql(true)
    end

    it "should delete an event by name" do
      resp = { object: "event", id: event_id, deleted: true }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Events.remove(event_name)
      expect(result[:deleted]).to eql(true)
    end

    it "should use DELETE /events/:identifier" do
      req = double("req", perform: { id: event_id, deleted: true })
      expect(Resend::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("events/#{CGI.escape(event_id)}")
        expect(verb).to eql("delete")
        req
      end
      Resend::Events.remove(event_id)
    end
  end

  describe "send" do
    it "should send an event with contact_id" do
      resp = { object: "event", event: event_name }
      params = { event: event_name, contact_id: "contact_abc123", payload: { plan: "pro" } }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Events.send(params)
      expect(result[:object]).to eql("event")
      expect(result[:event]).to eql(event_name)
    end

    it "should send an event with email" do
      resp = { object: "event", event: event_name }
      params = { event: event_name, email: "user@example.com" }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Events.send(params)
      expect(result[:event]).to eql(event_name)
    end

    it "should use POST /events/send" do
      params = { event: event_name, contact_id: "contact_abc123" }
      req = double("req", perform: { object: "event", event: event_name })
      expect(Resend::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("events/send")
        expect(verb).to eql("post")
        req
      end
      Resend::Events.send(params)
    end
  end

  describe "list" do
    it "should list events" do
      resp = {
        object: "list",
        has_more: false,
        data: [
          {
            id: event_id,
            name: event_name,
            schema: nil,
            created_at: "2024-01-01T00:00:00.000Z",
            updated_at: "2024-01-01T00:00:00.000Z"
          }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Events.list
      expect(result[:object]).to eql("list")
      expect(result[:data].length).to eql(1)
      expect(result[:has_more]).to eql(false)
      expect(result[:data].first[:id]).to eql(event_id)
    end

    it "should list events with pagination params" do
      resp = { object: "list", has_more: true, data: [{ id: event_id }] }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Events.list({ limit: 1 })
      expect(result[:has_more]).to eql(true)
    end

    it "should use GET /events" do
      req = double("req", perform: { object: "list", data: [], has_more: false })
      expect(Resend::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("events")
        expect(verb).to eql("get")
        req
      end
      Resend::Events.list
    end
  end
end
