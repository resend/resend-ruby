# frozen_string_literal: true

RSpec.describe "Contacts::Imports" do
  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  describe "create" do
    it "should create a contact import" do
      resp = {
        object: "contact_import",
        id: "479e3145-dd38-476b-932c-529ceb705947"
      }

      allow_any_instance_of(Resend::MultipartRequest).to receive(:perform).and_return(resp)
      result = Resend::Contacts::Imports.create(file: "email\nsteve@example.com")
      expect(result[:id]).to eql("479e3145-dd38-476b-932c-529ceb705947")
      expect(result[:object]).to eql("contact_import")
    end

    it "should raise when file is missing" do
      expect do
        Resend::Contacts::Imports.create({})
      end.to raise_error(ArgumentError, "Missing required `file` field")
    end

    it "should pass on_conflict and column_map options" do
      resp = { object: "contact_import", id: "479e3145-dd38-476b-932c-529ceb705947" }

      params = {
        file: "email,first_name\nsteve@example.com,Steve",
        on_conflict: "upsert",
        column_map: { "email" => "email", "first_name" => "first_name" }
      }

      allow_any_instance_of(Resend::MultipartRequest).to receive(:perform).and_return(resp)
      result = Resend::Contacts::Imports.create(params)
      expect(result[:id]).to eql("479e3145-dd38-476b-932c-529ceb705947")
    end

    it "should normalize segments array to id objects" do
      resp = { object: "contact_import", id: "479e3145-dd38-476b-932c-529ceb705947" }

      expect(Resend::MultipartRequest).to receive(:new).with(
        "contacts/imports",
        hash_including(segments: [{ id: "seg-123" }]),
        "post"
      ).and_call_original

      allow_any_instance_of(Resend::MultipartRequest).to receive(:perform).and_return(resp)
      Resend::Contacts::Imports.create(file: "email\nsteve@example.com", segments: ["seg-123"])
    end
  end

  describe "get" do
    it "should retrieve a contact import by id" do
      import_id = "479e3145-dd38-476b-932c-529ceb705947"
      resp = {
        object: "contact_import",
        id: import_id,
        status: "completed",
        created_at: "2023-10-06T23:47:56.678Z",
        counts: { total: 100, created: 80, updated: 10, skipped: 5, failed: 5 }
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Contacts::Imports.get(import_id)
      expect(result[:id]).to eql(import_id)
      expect(result[:status]).to eql("completed")
      expect(result[:counts][:total]).to eql(100)
    end

    it "should raise when id is missing" do
      expect do
        Resend::Contacts::Imports.get("")
      end.to raise_error(ArgumentError, "Missing required `id` field")
    end
  end

  describe "list" do
    it "should list contact imports" do
      resp = {
        object: "list",
        has_more: false,
        data: [
          {
            object: "contact_import",
            id: "479e3145-dd38-476b-932c-529ceb705947",
            status: "completed",
            created_at: "2023-10-06T23:47:56.678Z"
          }
        ]
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Contacts::Imports.list
      expect(result[:object]).to eql("list")
      expect(result[:data].length).to eql(1)
      expect(result[:data][0][:id]).to eql("479e3145-dd38-476b-932c-529ceb705947")
    end

    it "should list contact imports with status filter" do
      resp = { object: "list", has_more: false, data: [] }

      expect(Resend::Request).to receive(:new).with(
        include("status=completed"),
        {},
        "get"
      ).and_call_original

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      Resend::Contacts::Imports.list(status: "completed")
    end
  end
end
