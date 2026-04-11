# frozen_string_literal: true

RSpec.describe "Automations" do
  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  let(:automation_id) { "auto_abc123" }
  let(:run_id) { "run_xyz789" }

  let(:steps) do
    [
      { key: "trigger", type: "trigger", config: { event_name: "user.created" } },
      { key: "send_welcome", type: "send_email", config: { template: { id: "tpl_xxx" } } }
    ]
  end

  let(:connections) do
    [{ from: "trigger", to: "send_welcome", type: "default" }]
  end

  describe "create" do
    it "should create an automation" do
      resp = {
        object: "automation",
        id: automation_id
      }
      params = { name: "Welcome Automation", steps: steps, connections: connections }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Automations.create(params)
      expect(result[:id]).to eql(automation_id)
      expect(result[:object]).to eql("automation")
    end

    it "should use POST /automations" do
      params = { name: "Welcome Automation", steps: steps, connections: connections }
      req = double("req", perform: { id: automation_id })
      expect(Resend::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("automations")
        expect(verb).to eql("post")
        req
      end
      Resend::Automations.create(params)
    end
  end

  describe "get" do
    it "should retrieve an automation" do
      resp = {
        object: "automation",
        id: automation_id,
        name: "Welcome Automation",
        status: "enabled",
        created_at: "2024-01-01T00:00:00.000Z",
        updated_at: "2024-01-01T00:00:00.000Z",
        steps: steps,
        connections: connections
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Automations.get(automation_id)
      expect(result[:id]).to eql(automation_id)
      expect(result[:object]).to eql("automation")
      expect(result[:name]).to eql("Welcome Automation")
      expect(result[:status]).to eql("enabled")
    end

    it "should use GET /automations/:id" do
      req = double("req", perform: { id: automation_id })
      expect(Resend::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("automations/#{automation_id}")
        expect(verb).to eql("get")
        req
      end
      Resend::Automations.get(automation_id)
    end
  end

  describe "update" do
    it "should update an automation" do
      resp = { object: "automation", id: automation_id }
      params = { automation_id: automation_id, status: "enabled" }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Automations.update(params)
      expect(result[:id]).to eql(automation_id)
    end

    it "should use PATCH /automations/:id" do
      params = { automation_id: automation_id, status: "enabled" }
      req = double("req", perform: { id: automation_id })
      expect(Resend::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("automations/#{automation_id}")
        expect(verb).to eql("patch")
        req
      end
      Resend::Automations.update(params)
    end

    it "should NOT include automation_id in the request body" do
      params = { automation_id: automation_id, name: "Updated Name" }
      req = double("req", perform: { id: automation_id })
      expect(Resend::Request).to receive(:new).once do |_path, body, _verb|
        expect(body).not_to have_key(:automation_id)
        expect(body[:name]).to eql("Updated Name")
        req
      end
      Resend::Automations.update(params)
    end
  end

  describe "remove" do
    it "should delete an automation" do
      resp = { object: "automation", id: automation_id, deleted: true }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Automations.remove(automation_id)
      expect(result[:id]).to eql(automation_id)
      expect(result[:deleted]).to eql(true)
    end

    it "should use DELETE /automations/:id" do
      req = double("req", perform: { id: automation_id, deleted: true })
      expect(Resend::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("automations/#{automation_id}")
        expect(verb).to eql("delete")
        req
      end
      Resend::Automations.remove(automation_id)
    end
  end

  describe "stop" do
    it "should stop an automation" do
      resp = { object: "automation", id: automation_id, status: "disabled" }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Automations.stop(automation_id)
      expect(result[:id]).to eql(automation_id)
      expect(result[:status]).to eql("disabled")
    end

    it "should use POST /automations/:id/stop" do
      req = double("req", perform: { id: automation_id })
      expect(Resend::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("automations/#{automation_id}/stop")
        expect(verb).to eql("post")
        req
      end
      Resend::Automations.stop(automation_id)
    end
  end

  describe "list" do
    it "should list automations" do
      resp = {
        object: "list",
        has_more: false,
        data: [
          { id: automation_id, name: "Welcome Automation", status: "enabled", created_at: "2024-01-01T00:00:00.000Z" }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Automations.list
      expect(result[:object]).to eql("list")
      expect(result[:data].length).to eql(1)
      expect(result[:has_more]).to eql(false)
      expect(result[:data].first[:id]).to eql(automation_id)
    end

    it "should list automations with status filter" do
      resp = { object: "list", has_more: false, data: [{ id: automation_id, status: "enabled" }] }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Automations.list({ status: "enabled" })
      expect(result[:data].first[:status]).to eql("enabled")
    end

    it "should list automations with pagination params" do
      resp = { object: "list", has_more: true, data: [{ id: automation_id }] }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Automations.list({ limit: 1 })
      expect(result[:has_more]).to eql(true)
    end

    it "should use GET /automations" do
      req = double("req", perform: { object: "list", data: [], has_more: false })
      expect(Resend::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("automations")
        expect(verb).to eql("get")
        req
      end
      Resend::Automations.list
    end
  end

  describe "Runs" do
    it "should be accessible as Resend::Automations::Runs" do
      expect(Resend::Automations::Runs).to be_a(Module)
    end

    describe "list" do
      it "should list runs for an automation" do
        resp = {
          object: "list",
          has_more: false,
          data: [
            {
              id: run_id,
              status: "completed",
              started_at: "2024-01-01T00:00:00.000Z",
              completed_at: "2024-01-01T00:01:00.000Z",
              created_at: "2024-01-01T00:00:00.000Z"
            }
          ]
        }
        allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
        result = Resend::Automations::Runs.list(automation_id)
        expect(result[:object]).to eql("list")
        expect(result[:data].length).to eql(1)
        expect(result[:data].first[:id]).to eql(run_id)
        expect(result[:has_more]).to eql(false)
      end

      it "should use GET /automations/:id/runs" do
        req = double("req", perform: { object: "list", data: [], has_more: false })
        expect(Resend::Request).to receive(:new).once do |path, _body, verb|
          expect(path).to eql("automations/#{automation_id}/runs")
          expect(verb).to eql("get")
          req
        end
        Resend::Automations::Runs.list(automation_id)
      end

      it "should list runs with pagination params" do
        resp = { object: "list", has_more: true, data: [{ id: run_id }] }
        allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
        result = Resend::Automations::Runs.list(automation_id, { limit: 1 })
        expect(result[:has_more]).to eql(true)
      end
    end

    describe "get" do
      it "should retrieve a specific run" do
        resp = {
          object: "automation_run",
          id: run_id,
          status: "completed",
          started_at: "2024-01-01T00:00:00.000Z",
          completed_at: "2024-01-01T00:01:00.000Z",
          created_at: "2024-01-01T00:00:00.000Z",
          steps: []
        }
        allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
        result = Resend::Automations::Runs.get(automation_id, run_id)
        expect(result[:id]).to eql(run_id)
        expect(result[:object]).to eql("automation_run")
        expect(result[:status]).to eql("completed")
      end

      it "should use GET /automations/:id/runs/:run_id" do
        req = double("req", perform: { id: run_id })
        expect(Resend::Request).to receive(:new).once do |path, _body, verb|
          expect(path).to eql("automations/#{automation_id}/runs/#{run_id}")
          expect(verb).to eql("get")
          req
        end
        Resend::Automations::Runs.get(automation_id, run_id)
      end
    end
  end
end
