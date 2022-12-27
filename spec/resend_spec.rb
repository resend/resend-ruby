# frozen_string_literal: true

RSpec.describe Resend do
  it "has a version number" do
    expect(Resend::VERSION).not_to be nil
  end

  it "raise when required arguments are missing" do
    c = Resend::Client.new "re_123"

    from_missing = {
      "to": "test@test.com",
      "text": "t",
      "subject": "t"
    }
    expect { c.send_email from_missing }.to raise_error(ArgumentError)

    to_missing = {
      "from": "test@test.com",
      "text": "t",
      "subject": "t"
    }
    expect { c.send_email to_missing }.to raise_error(ArgumentError)

    subject_missing = {
      "from": "test@test.com",
      "to": "test@test.com",
      "text": "t",
    }
    expect { c.send_email subject_missing }.to raise_error(ArgumentError)
  end
end
