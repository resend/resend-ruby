# frozen_string_literal: true

RSpec.describe "Inboxes::Threads::Labels" do
  let(:inbox_id) { "b3e2b2b6-3f0e-4c8e-9ad3-2f43a1e2c7f1" }
  let(:thread_id) { "4d8e2a1c-9b3f-4c6d-8a21-3e5f7c9c0d12" }
  let(:label_id) { "7f9c1d2e-4a6b-4c3d-8e15-9b0a7c6d5e34" }
  let(:labels_path) { "inboxes/#{inbox_id}/threads/#{thread_id}/labels" }
  let(:label_list) { { object: "list", data: [{ "id" => label_id, "name" => "Urgent", "color" => "#E93D82" }] } }

  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  def expect_request(path, body, verb, resp)
    expect(Resend::Request).to receive(:new).with(path, body, verb).and_return(double("req", perform: resp))
  end

  describe "add" do
    it "should add labels to a thread" do
      expect_request(labels_path, { labels: [label_id] }, "post", label_list)

      labels = Resend::Inboxes::Threads::Labels.add(inbox_id: inbox_id, thread_id: thread_id, labels: [label_id])
      expect(labels[:data].first["id"]).to eql(label_id)
    end

    it "should accept the inbox email address" do
      expect_request("inboxes/support%40acme.com/threads/#{thread_id}/labels", { labels: [label_id] }, "post",
                     label_list)

      Resend::Inboxes::Threads::Labels.add(inbox_id: "support@acme.com", thread_id: thread_id, labels: [label_id])
    end

    it "should raise when labels is missing" do
      expect do
        Resend::Inboxes::Threads::Labels.add(inbox_id: inbox_id, thread_id: thread_id)
      end.to raise_error(ArgumentError, "labels is required")
    end

    it "should raise when thread_id is missing" do
      expect do
        Resend::Inboxes::Threads::Labels.add(inbox_id: inbox_id, labels: [label_id])
      end.to raise_error(ArgumentError, "thread_id is required")
    end
  end

  describe "set" do
    it "should replace the labels of a thread" do
      expect_request(labels_path, { labels: [] }, "put", { object: "list", data: [] })

      labels = Resend::Inboxes::Threads::Labels.set(inbox_id: inbox_id, thread_id: thread_id, labels: [])
      expect(labels[:data]).to eql([])
    end

    it "should raise when labels is missing" do
      expect do
        Resend::Inboxes::Threads::Labels.set(inbox_id: inbox_id, thread_id: thread_id)
      end.to raise_error(ArgumentError, "labels is required")
    end

    it "should raise when inbox_id is missing" do
      expect do
        Resend::Inboxes::Threads::Labels.set(thread_id: thread_id, labels: [])
      end.to raise_error(ArgumentError, "inbox_id is required")
    end
  end

  describe "remove" do
    it "should remove a label from a thread" do
      expect_request("#{labels_path}/#{label_id}", {}, "delete", { object: "list", data: [] })

      labels = Resend::Inboxes::Threads::Labels.remove(inbox_id: inbox_id, thread_id: thread_id, label_id: label_id)
      expect(labels[:object]).to eql("list")
    end

    it "should raise when label_id is missing" do
      expect do
        Resend::Inboxes::Threads::Labels.remove(inbox_id: inbox_id, thread_id: thread_id)
      end.to raise_error(ArgumentError, "label_id is required")
    end
  end
end
