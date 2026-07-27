# frozen_string_literal: true

RSpec.describe "Suppressions" do
  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  describe "add" do
    it "should add a suppression" do
      resp = {
        object: "suppression",
        id: "e169aa45-1ecf-4183-9955-b1499d5701d3"
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      suppression = Resend::Suppressions.add(email: "steve.wozniak@gmail.com")
      expect(suppression[:id]).to eql("e169aa45-1ecf-4183-9955-b1499d5701d3")
      expect(suppression[:object]).to eql("suppression")
    end

    it "should post the email to the suppressions path" do
      resp = { object: "suppression", id: "e169aa45-1ecf-4183-9955-b1499d5701d3" }

      params = { email: "steve.wozniak@gmail.com" }

      expect(Resend::Request).to receive(:new).with("suppressions", params, "post").and_call_original
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      Resend::Suppressions.add(params)
    end
  end

  describe "list" do
    it "should list suppressions" do
      resp = {
        object: "list",
        has_more: false,
        data: [
          {
            "id" => "e169aa45-1ecf-4183-9955-b1499d5701d3",
            "email" => "steve.wozniak@gmail.com",
            "origin" => "bounce",
            "source_id" => "479e3145-dd38-476b-932c-529ceb705947",
            "created_at" => "2023-10-06T23:47:56.678Z"
          }
        ]
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Suppressions.list
      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to be(false)
      expect(result[:data].length).to eql(1)
      expect(result[:data][0]["id"]).to eql("e169aa45-1ecf-4183-9955-b1499d5701d3")
      expect(result[:data][0]["origin"]).to eql("bounce")
      expect(result[:data][0]["source_id"]).to eql("479e3145-dd38-476b-932c-529ceb705947")
      expect(result[:data][0]["created_at"]).to eql("2023-10-06T23:47:56.678Z")
    end

    it "should not expose an object field on list entries" do
      resp = {
        object: "list",
        has_more: false,
        data: [
          {
            "id" => "e169aa45-1ecf-4183-9955-b1499d5701d3",
            "email" => "steve.wozniak@gmail.com",
            "origin" => "bounce",
            "source_id" => "479e3145-dd38-476b-932c-529ceb705947",
            "created_at" => "2023-10-06T23:47:56.678Z"
          }
        ]
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Suppressions.list
      expect(result[:data][0]).not_to have_key("object")
      expect(result[:data][0].keys).to eql(%w[id email origin source_id created_at])
    end

    it "should list suppressions with a null source_id" do
      resp = {
        object: "list",
        has_more: false,
        data: [
          {
            "id" => "e169aa45-1ecf-4183-9955-b1499d5701d3",
            "email" => "steve.wozniak@gmail.com",
            "origin" => "manual",
            "source_id" => nil,
            "created_at" => "2023-10-06T23:47:56.678Z"
          }
        ]
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Suppressions.list
      expect(result[:data][0]["origin"]).to eql("manual")
      expect(result[:data][0]["source_id"]).to be_nil
    end

    it "should list suppressions with origin and pagination params" do
      resp = { object: "list", has_more: false, data: [] }

      expect(Resend::Request).to receive(:new).with(
        "suppressions?origin=bounce&limit=10&after=e169aa45-1ecf-4183-9955-b1499d5701d3",
        {},
        "get"
      ).and_call_original

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      Resend::Suppressions.list(origin: "bounce", limit: 10, after: "e169aa45-1ecf-4183-9955-b1499d5701d3")
    end
  end

  describe "get" do
    it "should retrieve a suppression by id" do
      resp = {
        object: "suppression",
        id: "e169aa45-1ecf-4183-9955-b1499d5701d3",
        email: "steve.wozniak@gmail.com",
        origin: "complaint",
        source_id: "479e3145-dd38-476b-932c-529ceb705947",
        created_at: "2023-10-06T23:47:56.678Z"
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      suppression = Resend::Suppressions.get("e169aa45-1ecf-4183-9955-b1499d5701d3")
      expect(suppression[:id]).to eql("e169aa45-1ecf-4183-9955-b1499d5701d3")
      expect(suppression[:email]).to eql("steve.wozniak@gmail.com")
      expect(suppression[:origin]).to eql("complaint")
      expect(suppression[:created_at]).to eql("2023-10-06T23:47:56.678Z")
      expect(suppression[:object]).to eql("suppression")
    end

    it "should retrieve a suppression with a null source_id" do
      resp = {
        object: "suppression",
        id: "e169aa45-1ecf-4183-9955-b1499d5701d3",
        email: "steve.wozniak@gmail.com",
        origin: "manual",
        source_id: nil,
        created_at: "2023-10-06T23:47:56.678Z"
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      suppression = Resend::Suppressions.get("e169aa45-1ecf-4183-9955-b1499d5701d3")
      expect(suppression[:origin]).to eql("manual")
      expect(suppression[:source_id]).to be_nil
    end

    it "should url encode an email address in the path" do
      resp = { object: "suppression", id: "e169aa45-1ecf-4183-9955-b1499d5701d3" }

      expect(Resend::Request).to receive(:new).with(
        "suppressions/steve.wozniak%2Bnews%40gmail.com",
        {},
        "get"
      ).and_call_original

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      Resend::Suppressions.get("steve.wozniak+news@gmail.com")
    end

    it "should raise when id_or_email is missing" do
      expect do
        Resend::Suppressions.get("")
      end.to raise_error(ArgumentError, "Missing required `id_or_email` field")
    end
  end

  describe "remove" do
    it "should remove a suppression by id" do
      resp = {
        object: "suppression",
        id: "e169aa45-1ecf-4183-9955-b1499d5701d3",
        deleted: true
      }

      expect(Resend::Request).to receive(:new).with(
        "suppressions/e169aa45-1ecf-4183-9955-b1499d5701d3",
        {},
        "delete"
      ).and_call_original

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Suppressions.remove("e169aa45-1ecf-4183-9955-b1499d5701d3")
      expect(result[:id]).to eql("e169aa45-1ecf-4183-9955-b1499d5701d3")
      expect(result[:deleted]).to be(true)
    end

    it "should url encode an email address in the path" do
      resp = { object: "suppression", id: "e169aa45-1ecf-4183-9955-b1499d5701d3", deleted: true }

      expect(Resend::Request).to receive(:new).with(
        "suppressions/steve.wozniak%2Bnews%40gmail.com",
        {},
        "delete"
      ).and_call_original

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      Resend::Suppressions.remove("steve.wozniak+news@gmail.com")
    end

    it "should raise when id_or_email is missing" do
      expect do
        Resend::Suppressions.remove(nil)
      end.to raise_error(ArgumentError, "Missing required `id_or_email` field")
    end
  end
end
