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
end
