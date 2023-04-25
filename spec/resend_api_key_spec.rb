# frozen_string_literal: true

RSpec.describe "API Keys tests" do

  describe "name" do
    it "name is missing" do
      c = Resend::Client.new "re_123"
      name_missing = {
        "permission": "1"
      }
      expect { c.create_api_key name_missing }.to raise_error(ArgumentError, /Argument 'name' is required/)
    end

    it "name is blank" do
      c = Resend::Client.new "re_123"
      name_blank = {
        "name": ""
      }
      expect { c.create_api_key name_blank }.to raise_error(ArgumentError, /Argument 'name' can not be blank/)
    end

    it "name is the only argument" do
      c = Resend::Client.new "re_123"
      params = {
        "name": "name1"
      }
      expect_any_instance_of(Resend::Request).to receive(:perform)
      expect { c.create_api_key params }.not_to raise_error
    end
  end

  describe "permission" do
    it "permission is present but blank" do
      c = Resend::Client.new "re_123"
      permission_blank = {
        "name": "hi",
        "permission": ""
      }
      expect { c.create_api_key permission_blank }.to raise_error(ArgumentError, /Argument 'permission' can not be blank/)
    end

    it "permission is invalid" do
      c = Resend::Client.new "re_123"
      invalid = {
        "name": "hi",
        "permission": "invl"
      }
      expect { c.create_api_key invalid }.to raise_error(ArgumentError, /invl is invalid, must be 'full_access' or 'sending_access/)
    end

    it "permission is valid" do
      c = Resend::Client.new "re_123"
      valid = {
        "name": "hi",
        "permission": "full_access"
      }
      expect_any_instance_of(Resend::Request).to receive(:perform)
      expect { c.create_api_key valid }.not_to raise_error
    end
  end

  describe "domain_id" do
    it "domain_id is present and blank" do
      c = Resend::Client.new "re_123"
      params = {
        "name": "hi",
        "permission": "full_access",
        "domain_id": ""
      }
      expect { c.create_api_key params }.to raise_error(ArgumentError, /Argument 'domain_id' can not be blank/)
    end
  end

end
