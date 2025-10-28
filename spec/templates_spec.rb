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

  describe "update" do
    it "should update a template" do
      resp = {
        "id": "34a080c9-b17d-4187-ad80-5af20266e535",
        "object": "template"
      }
      params = {
        "name": "updated-welcome-email",
        "html": "<strong>Updated content</strong>"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Templates.update("34a080c9-b17d-4187-ad80-5af20266e535", params)
      expect(result[:id]).to eql("34a080c9-b17d-4187-ad80-5af20266e535")
      expect(result[:object]).to eql("template")
    end

    it "should update a template with variables" do
      resp = {
        "id": "34a080c9-b17d-4187-ad80-5af20266e535",
        "object": "template"
      }
      params = {
        "name": "updated-welcome-email",
        "html": "<strong>Hello {{{NAME}}}</strong>",
        "variables": [
          {
            "key": "NAME",
            "type": "string",
            "fallback_value": "Guest"
          }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Templates.update("34a080c9-b17d-4187-ad80-5af20266e535", params)
      expect(result[:id]).to eql("34a080c9-b17d-4187-ad80-5af20266e535")
      expect(result[:object]).to eql("template")
    end

    it "should update a template by alias" do
      resp = {
        "id": "34a080c9-b17d-4187-ad80-5af20266e535",
        "object": "template"
      }
      params = {
        "name": "updated-reset-password",
        "subject": "Reset Your Password Now"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Templates.update("reset-password", params)
      expect(result[:id]).to eql("34a080c9-b17d-4187-ad80-5af20266e535")
      expect(result[:object]).to eql("template")
    end
  end

  describe "publish" do
    it "should publish a template by ID" do
      resp = {
        "id": "34a080c9-b17d-4187-ad80-5af20266e535",
        "object": "template"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Templates.publish("34a080c9-b17d-4187-ad80-5af20266e535")
      expect(result[:id]).to eql("34a080c9-b17d-4187-ad80-5af20266e535")
      expect(result[:object]).to eql("template")
    end

    it "should publish a template by alias" do
      resp = {
        "id": "34a080c9-b17d-4187-ad80-5af20266e535",
        "object": "template"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Templates.publish("welcome")
      expect(result[:id]).to eql("34a080c9-b17d-4187-ad80-5af20266e535")
      expect(result[:object]).to eql("template")
    end
  end

  describe "duplicate" do
    it "should duplicate a template by ID" do
      resp = {
        "id": "e169aa45-1ecf-4183-9955-b1499d5701d3",
        "object": "template"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Templates.duplicate("34a080c9-b17d-4187-ad80-5af20266e535")
      expect(result[:id]).to eql("e169aa45-1ecf-4183-9955-b1499d5701d3")
      expect(result[:object]).to eql("template")
    end

    it "should duplicate a template by alias" do
      resp = {
        "id": "e169aa45-1ecf-4183-9955-b1499d5701d3",
        "object": "template"
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Templates.duplicate("welcome")
      expect(result[:id]).to eql("e169aa45-1ecf-4183-9955-b1499d5701d3")
      expect(result[:object]).to eql("template")
    end
  end

  describe "list" do
    it "should list templates" do
      resp = {
        "object": "list",
        "data": [
          {
            "id": "e169aa45-1ecf-4183-9955-b1499d5701d3",
            "name": "reset-password",
            "status": "draft",
            "published_at": nil,
            "created_at": "2023-10-06T23:47:56.678Z",
            "updated_at": "2023-10-06T23:47:56.678Z",
            "alias": "reset-password"
          },
          {
            "id": "b7f9c2e1-1234-4abc-9def-567890abcdef",
            "name": "welcome-message",
            "status": "published",
            "published_at": "2023-10-06T23:47:56.678Z",
            "created_at": "2023-10-06T23:47:56.678Z",
            "updated_at": "2023-10-06T23:47:56.678Z",
            "alias": "welcome-message"
          }
        ],
        "has_more": false
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      templates = Resend::Templates.list[:data]

      expect(templates.length).to eql(2)
      expect(templates[0][:id]).to eql("e169aa45-1ecf-4183-9955-b1499d5701d3")
      expect(templates[0][:name]).to eql("reset-password")
      expect(templates[0][:status]).to eql("draft")
      expect(templates[0][:alias]).to eql("reset-password")

      expect(templates[1][:id]).to eql("b7f9c2e1-1234-4abc-9def-567890abcdef")
      expect(templates[1][:name]).to eql("welcome-message")
      expect(templates[1][:status]).to eql("published")
      expect(templates[1][:alias]).to eql("welcome-message")
    end

    it "should list templates with pagination" do
      resp = {
        "object": "list",
        "data": [],
        "has_more": false
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)

      result = Resend::Templates.list({ limit: 2, after: "34a080c9-b17d-4187-ad80-5af20266e535" })
      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to eql(false)
    end
  end

  describe "remove" do
    it "should remove template by ID" do
      resp = {
        "object": "template",
        "id": "34a080c9-b17d-4187-ad80-5af20266e535",
        "deleted": true
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Templates.remove("34a080c9-b17d-4187-ad80-5af20266e535")
      expect(result[:id]).to eql("34a080c9-b17d-4187-ad80-5af20266e535")
      expect(result[:deleted]).to eql(true)
    end

    it "should remove template by alias" do
      resp = {
        "object": "template",
        "id": "34a080c9-b17d-4187-ad80-5af20266e535",
        "deleted": true
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      result = Resend::Templates.remove("welcome")
      expect(result[:id]).to eql("34a080c9-b17d-4187-ad80-5af20266e535")
      expect(result[:deleted]).to eql(true)
    end
  end
end
