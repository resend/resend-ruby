# frozen_string_literal: true

RSpec.describe "Templates" do
  before do
    Resend.configure do |config|
      config.api_key = "re_123"
    end
  end

  describe "create" do
    it "should create template" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794",
        "object": "template"
      }
      params = {
        "name": "welcome-email",
        "html": "<strong>Hey, {{{NAME}}}, you are {{{AGE}}} years old.</strong>"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Templates.create(params)
      expect(result[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
      expect(result[:object]).to eql("template")
    end

    it "should create template with variables" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794",
        "object": "template"
      }
      params = {
        "name": "welcome-email",
        "html": "<strong>Hey, {{{NAME}}}, you are {{{AGE}}} years old.</strong>",
        "variables": [
          {
            "key": "NAME",
            "type": "string",
            "fallback_value": "user"
          },
          {
            "key": "AGE",
            "type": "number",
            "fallback_value": 25
          }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Templates.create(params)
      expect(result[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
      expect(result[:object]).to eql("template")
    end

    it "should create template with all optional fields" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794",
        "object": "template"
      }
      params = {
        "name": "welcome-email",
        "alias": "welcome",
        "from": "Acme <onboarding@resend.dev>",
        "subject": "Welcome to our platform",
        "reply_to": "support@resend.dev",
        "html": "<strong>Hey, {{{NAME}}}!</strong>",
        "text": "Hey, {{{NAME}}}!",
        "variables": [
          {
            "key": "NAME",
            "type": "string",
            "fallback_value": "user"
          }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Templates.create(params)
      expect(result[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
      expect(result[:object]).to eql("template")
    end
  end

  describe "get" do
    it "should retrieve a template by ID" do
      resp = {
        "object": "template",
        "id": "34a080c9-b17d-4187-ad80-5af20266e535",
        "alias": "reset-password",
        "name": "reset-password",
        "created_at": "2023-10-06T23:47:56.678Z",
        "updated_at": "2023-10-06T23:47:56.678Z",
        "status": "published",
        "published_at": "2023-10-06T23:47:56.678Z",
        "from": "John Doe <john.doe@example.com>",
        "subject": "Hello, world!",
        "reply_to": nil,
        "html": "<h1>Hello, world!</h1>",
        "text": "Hello, world!",
        "variables": [
          {
            "id" => "e169aa45-1ecf-4183-9955-b1499d5701d3",
            "key" => "user_name",
            "type" => "string",
            "fallback_value" => "John Doe",
            "created_at" => "2023-10-06T23:47:56.678Z",
            "updated_at" => "2023-10-06T23:47:56.678Z"
          }
        ]
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      template = Resend::Templates.get("34a080c9-b17d-4187-ad80-5af20266e535")

      expect(template[:object]).to eql("template")
      expect(template[:id]).to eql("34a080c9-b17d-4187-ad80-5af20266e535")
      expect(template[:alias]).to eql("reset-password")
      expect(template[:name]).to eql("reset-password")
      expect(template[:status]).to eql("published")
      expect(template[:from]).to eql("John Doe <john.doe@example.com>")
      expect(template[:subject]).to eql("Hello, world!")
      expect(template[:html]).to eql("<h1>Hello, world!</h1>")
      expect(template[:text]).to eql("Hello, world!")
      expect(template[:variables].length).to eql(1)
      expect(template[:variables][0]['key']).to eql("user_name")
      expect(template[:variables][0]['type']).to eql("string")
      expect(template[:variables][0]['fallback_value']).to eql("John Doe")
    end

    it "should retrieve a template by alias" do
      resp = {
        "object": "template",
        "id": "34a080c9-b17d-4187-ad80-5af20266e535",
        "alias": "reset-password",
        "name": "reset-password",
        "created_at": "2023-10-06T23:47:56.678Z",
        "updated_at": "2023-10-06T23:47:56.678Z",
        "status": "published",
        "published_at": "2023-10-06T23:47:56.678Z",
        "from": "John Doe <john.doe@example.com>",
        "subject": "Hello, world!",
        "reply_to": nil,
        "html": "<h1>Hello, world!</h1>",
        "text": "Hello, world!",
        "variables": []
      }

      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      template = Resend::Templates.get("reset-password")

      expect(template[:object]).to eql("template")
      expect(template[:id]).to eql("34a080c9-b17d-4187-ad80-5af20266e535")
      expect(template[:alias]).to eql("reset-password")
    end
  end
end
