# frozen_string_literal: true

RSpec.describe "Suppressions::Batch" do
  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  describe "add" do
    it "should add multiple suppressions" do
      resp = {
        data: [
          { object: "suppression", id: "e169aa45-1ecf-4183-9955-b1499d5701d3" },
          { object: "suppression", id: "1b3d4b95-2b7d-4c5f-9b1f-2d1a5a3f8e12" }
        ]
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Suppressions::Batch.add(emails: ["steve.wozniak@gmail.com", "steve.jobs@gmail.com"])
      expect(result[:data].length).to eql(2)
      expect(result[:data][0][:id]).to eql("e169aa45-1ecf-4183-9955-b1499d5701d3")
      expect(result[:data][0][:object]).to eql("suppression")
    end

    it "should post the emails to the batch add path" do
      resp = { data: [] }

      params = { emails: ["steve.wozniak@gmail.com"] }

      expect(Resend::Request).to receive(:new).with("suppressions/batch/add", params, "post").and_call_original
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      Resend::Suppressions::Batch.add(params)
    end
  end

  describe "remove" do
    it "should remove multiple suppressions by email" do
      resp = {
        data: [
          { object: "suppression", id: "e169aa45-1ecf-4183-9955-b1499d5701d3", deleted: true }
        ]
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Suppressions::Batch.remove(emails: ["steve.wozniak@gmail.com"])
      expect(result[:data].length).to eql(1)
      expect(result[:data][0][:deleted]).to be(true)
    end

    it "should remove multiple suppressions by id" do
      resp = {
        data: [
          { object: "suppression", id: "e169aa45-1ecf-4183-9955-b1499d5701d3", deleted: true }
        ]
      }

      expect(Resend::Request).to receive(:new).with(
        "suppressions/batch/remove",
        { ids: ["e169aa45-1ecf-4183-9955-b1499d5701d3"] },
        "post"
      ).and_call_original

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Suppressions::Batch.remove(ids: ["e169aa45-1ecf-4183-9955-b1499d5701d3"])
      expect(result[:data][0][:id]).to eql("e169aa45-1ecf-4183-9955-b1499d5701d3")
    end

    it "should omit ids from the request body when removing by email" do
      body = nil

      expect(Resend::Request).to receive(:new) do |_path, request_body, _verb|
        body = request_body
        instance_double(Resend::Request, perform: { data: [] })
      end

      Resend::Suppressions::Batch.remove(emails: ["steve.wozniak@gmail.com"])

      expect(body).not_to have_key(:ids)
      expect(body.to_json).to eql('{"emails":["steve.wozniak@gmail.com"]}')
    end

    it "should omit emails from the request body when removing by id" do
      body = nil

      expect(Resend::Request).to receive(:new) do |_path, request_body, _verb|
        body = request_body
        instance_double(Resend::Request, perform: { data: [] })
      end

      Resend::Suppressions::Batch.remove(ids: ["e169aa45-1ecf-4183-9955-b1499d5701d3"])

      expect(body).not_to have_key(:emails)
      expect(body.to_json).to eql('{"ids":["e169aa45-1ecf-4183-9955-b1499d5701d3"]}')
    end

    it "should ignore an explicitly nil ids and send only emails" do
      body = nil

      expect(Resend::Request).to receive(:new) do |_path, request_body, _verb|
        body = request_body
        instance_double(Resend::Request, perform: { data: [] })
      end

      Resend::Suppressions::Batch.remove(emails: ["steve.wozniak@gmail.com"], ids: nil)

      expect(body.to_json).to eql('{"emails":["steve.wozniak@gmail.com"]}')
    end

    it "should accept string keyed emails" do
      body = nil

      expect(Resend::Request).to receive(:new) do |_path, request_body, _verb|
        body = request_body
        instance_double(Resend::Request, perform: { data: [] })
      end

      Resend::Suppressions::Batch.remove("emails" => ["steve.wozniak@gmail.com"])

      expect(body).not_to have_key(:ids)
      expect(body.to_json).to eql('{"emails":["steve.wozniak@gmail.com"]}')
    end

    it "should accept string keyed ids" do
      body = nil

      expect(Resend::Request).to receive(:new) do |_path, request_body, _verb|
        body = request_body
        instance_double(Resend::Request, perform: { data: [] })
      end

      Resend::Suppressions::Batch.remove("ids" => ["e169aa45-1ecf-4183-9955-b1499d5701d3"])

      expect(body).not_to have_key(:emails)
      expect(body.to_json).to eql('{"ids":["e169aa45-1ecf-4183-9955-b1499d5701d3"]}')
    end

    it "should raise when both string keyed emails and ids are given" do
      expect do
        Resend::Suppressions::Batch.remove(
          "emails" => ["steve.wozniak@gmail.com"],
          "ids" => ["e169aa45-1ecf-4183-9955-b1499d5701d3"]
        )
      end.to raise_error(ArgumentError, "Provide either `emails` or `ids`, but not both")
    end

    it "should raise when neither emails nor ids is given" do
      expect do
        Resend::Suppressions::Batch.remove({})
      end.to raise_error(ArgumentError, "Missing required `emails` or `ids` field")
    end

    it "should raise when both emails and ids are given" do
      expect do
        Resend::Suppressions::Batch.remove(
          emails: ["steve.wozniak@gmail.com"],
          ids: ["e169aa45-1ecf-4183-9955-b1499d5701d3"]
        )
      end.to raise_error(ArgumentError, "Provide either `emails` or `ids`, but not both")
    end
  end
end
