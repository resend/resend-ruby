# frozen_string_literal: true

RSpec.describe "Inboxes::Threads" do
  let(:inbox_id) { "b3e2b2b6-3f0e-4c8e-9ad3-2f43a1e2c7f1" }
  let(:thread_id) { "4d8e2a1c-9b3f-4c6d-8a21-3e5f7c9c0d12" }
  let(:label_id) { "7f9c1d2e-4a6b-4c3d-8e15-9b0a7c6d5e34" }
  let(:other_label_id) { "2b6d0f4e-8a1c-4e3b-9d57-1c0e8a6f4b21" }

  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  def expect_request(path, body, verb, resp)
    expect(Resend::Request).to receive(:new).with(path, body, verb).and_return(double("req", perform: resp))
  end

  describe "list" do
    it "should list threads" do
      resp = {
        object: "list",
        has_more: false,
        data: [{ "id" => thread_id, "subject" => "Refund", "folder" => "inbox", "read" => false, "labels" => [] }]
      }
      expect_request("inboxes/#{inbox_id}/threads", {}, "get", resp)

      threads = Resend::Inboxes::Threads.list(inbox_id: inbox_id)
      expect(threads[:data].first["id"]).to eql(thread_id)
    end

    it "should join array filters with commas" do
      expect_request(
        "inboxes/#{inbox_id}/threads?folders=inbox%2Csent&labels=#{label_id}&read=false&limit=5",
        {}, "get", { object: "list", data: [] }
      )

      Resend::Inboxes::Threads.list(inbox_id: inbox_id, folders: %w[inbox sent], labels: [label_id], read: false,
                                    limit: 5)
    end

    it "should raise when inbox_id is missing" do
      expect { Resend::Inboxes::Threads.list({}) }.to raise_error(ArgumentError, "inbox_id is required")
    end
  end

  describe "search" do
    it "should search threads" do
      path = "inboxes/#{inbox_id}/threads/search?query=invoice+-draft&from=isabella%40example.com%2Ccarolina" \
             "&has_attachment=true&start_date=2026-09-01&end_date=2026-09-30&folders=inbox"
      resp = { object: "list", has_more: false, data: [{ "id" => thread_id }] }
      expect_request(path, {}, "get", resp)

      threads = Resend::Inboxes::Threads.search(
        inbox_id: inbox_id,
        query: "invoice -draft",
        from: %w[isabella@example.com carolina],
        has_attachment: true,
        start_date: "2026-09-01",
        end_date: "2026-09-30",
        folders: ["inbox"]
      )
      expect(threads[:data].first["id"]).to eql(thread_id)
    end

    it "should raise when inbox_id is missing" do
      expect { Resend::Inboxes::Threads.search(query: "x") }.to raise_error(ArgumentError, "inbox_id is required")
    end
  end

  describe "get" do
    it "should retrieve a thread" do
      resp = { object: "inbox_thread", id: thread_id, subject: "Refund", folder: "inbox", labels: [], read: true }
      expect_request("inboxes/#{inbox_id}/threads/#{thread_id}", {}, "get", resp)

      thread = Resend::Inboxes::Threads.get(inbox_id: inbox_id, thread_id: thread_id)
      expect(thread[:folder]).to eql("inbox")
    end

    it "should raise when thread_id is missing" do
      expect do
        Resend::Inboxes::Threads.get(inbox_id: inbox_id)
      end.to raise_error(ArgumentError, "thread_id is required")
    end
  end

  describe "update" do
    it "should update a thread with label changes" do
      body = { read: true, folder: "archive", add_label_ids: [label_id], remove_label_ids: [other_label_id] }
      resp = { object: "inbox_thread", id: thread_id, folder: "archive", read: true,
               labels: [{ "id" => label_id, "name" => "Urgent", "color" => "#E93D82" }] }
      expect_request("inboxes/#{inbox_id}/threads/#{thread_id}", body, "patch", resp)

      thread = Resend::Inboxes::Threads.update(inbox_id: inbox_id, thread_id: thread_id, **body)
      expect(thread[:labels].first["id"]).to eql(label_id)
    end

    it "should raise when thread_id is missing" do
      expect do
        Resend::Inboxes::Threads.update(inbox_id: inbox_id, read: true)
      end.to raise_error(ArgumentError, "thread_id is required")
    end
  end

  describe "remove" do
    it "should remove a thread" do
      expect_request("inboxes/#{inbox_id}/threads/#{thread_id}", {}, "delete",
                     { object: "inbox_thread", id: thread_id, deleted: true })

      thread = Resend::Inboxes::Threads.remove(inbox_id: inbox_id, thread_id: thread_id)
      expect(thread[:deleted]).to be true
    end

    it "should raise when inbox_id is missing" do
      expect do
        Resend::Inboxes::Threads.remove(thread_id: thread_id)
      end.to raise_error(ArgumentError, "inbox_id is required")
    end
  end
end
