# frozen_string_literal: true

RSpec.describe "Topics" do

  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  describe "create" do
    it "should create topic" do
      resp = {
        "id": "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      }
      params = {
        "name": "Weekly Newsletter",
        "default_subscription": "opt_in",
        "description": "Our weekly newsletter with the latest updates"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(Resend::Topics.create(params)[:id]).to eql("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")
    end
  end

  describe "get topic" do
    it "should retrieve a topic" do
      resp = {
        "id": "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        "name": "Weekly Newsletter",
        "description": "Weekly newsletter for our subscribers",
        "default_subscription": "opt_in",
        "created_at": "2023-04-08T00:11:13.110779+00:00"
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      topic = Resend::Topics.get("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")

      expect(topic[:id]).to eql "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      expect(topic[:name]).to eql "Weekly Newsletter"
      expect(topic[:description]).to eql "Weekly newsletter for our subscribers"
      expect(topic[:default_subscription]).to eql "opt_in"
      expect(topic[:created_at]).to eql "2023-04-08T00:11:13.110779+00:00"
    end
  end

  describe "update" do
    it "should update topic" do
      resp = {
        "id": "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      }
      params = {
        "topic_id": "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        "name": "Weekly Newsletter - Updated",
        "description": "Updated description"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      expect(Resend::Topics.update(params)[:id]).to eql("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")
    end
  end

  describe "list" do
    it "should list topics" do
      resp = {
        "object": "list",
        "has_more": false,
        "data": [
          {
            "id": "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
            "name": "Weekly Newsletter",
            "description": "Weekly newsletter for our subscribers",
            "default_subscription": "opt_in",
            "created_at": "2023-04-08T00:11:13.110779+00:00"
          },
          {
            "id": "c7e35c9f-1fc2-5db5-cf1d-46af8e4c2f91",
            "name": "Monthly Updates",
            "description": "Monthly product updates",
            "default_subscription": "opt_out",
            "created_at": "2023-04-09T10:15:20.220890+00:00"
          }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      topics = Resend::Topics.list[:data]

      expect(topics.length).to eql(2)

      expect(topics[0][:id]).to eql("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")
      expect(topics[0][:name]).to eql("Weekly Newsletter")
      expect(topics[0][:description]).to eql("Weekly newsletter for our subscribers")
      expect(topics[0][:default_subscription]).to eql("opt_in")
      expect(topics[0][:created_at]).to eql("2023-04-08T00:11:13.110779+00:00")

      expect(topics[1][:id]).to eql("c7e35c9f-1fc2-5db5-cf1d-46af8e4c2f91")
      expect(topics[1][:name]).to eql("Monthly Updates")
      expect(topics[1][:description]).to eql("Monthly product updates")
      expect(topics[1][:default_subscription]).to eql("opt_out")
      expect(topics[1][:created_at]).to eql("2023-04-09T10:15:20.220890+00:00")
    end
  end

  describe "remove" do
    it "should remove topic" do
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return("")
      expect { Resend::Topics.remove }.not_to raise_error
    end
  end

end
