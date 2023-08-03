# frozen_string_literal: true

require "rails"
require "json"
require "resend"
require "resend/railtie"
require "spec_helper"
require "action_mailer"
require "pry-byebug"

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :test

class TestMailer < ActionMailer::Base
  default from: "test@example.com"

  def html_text_msg(to, subject)
    headers = {
      "X-Entity-Ref-ID": "123",
    }
    mail(to: to, subject: subject, headers: headers) do |format|
      format.html { render html: "<p>HTML!</p>".html_safe }
      format.text { render plain: "text" }
    end
  end

  def text_only(to, subject)
    mail(to: to, subject: subject) do |format|
      format.text { render plain: "text" }
    end
  end

  def html_only(to, subject)
    mail(to: to, subject: subject) do |format|
      format.html { render html: "<p>HTML!</p>".html_safe }
    end
  end

  def with_attachment(to, subject)
    attachments['invoice.pdf'] = {
      :content => File.read('resources/invoice.pdf'),
      :mime_type => 'application/pdf',
    }
    mail(to: to, subject: subject) do |format|
      format.text { render plain: "txt" }
      format.html { render html: "<p>html</p>".html_safe }
    end
  end
end

class TestMailerWithDisplayName < TestMailer
  default from: "Test <test@example.com>"
end

RSpec.describe "Resend::Mailer" do
  before do
    @mailer = Resend::Mailer.new({ api_key: "123" })
  end

  it "properly creates a message body" do
    message = TestMailer.html_text_msg("test@example.org", "Test!")
    body = @mailer.build_resend_params(message)
    expect(body[:from]).to eql("test@example.com")
    expect(body[:to]).to eql(["test@example.org"])
    expect(body[:html]).to eql("<p>HTML!</p>")
    expect(body[:text]).to eql("text")
    expect(body[:headers][:"X-Entity-Ref-ID"]).to eql("123")
  end

  it "properly creates a html only msg" do
    message = TestMailer.html_only("test@example.org", "Test!")
    body = @mailer.build_resend_params(message)
    expect(body[:from]).to eql("test@example.com")
    expect(body[:to]).to eql(["test@example.org"])
    expect(body[:html]).to eql("<p>HTML!</p>")
    expect(body[:text]).to be nil
  end

  it "properly creates a text only msg" do
    message = TestMailer.text_only("test@example.org", "Test!")
    body = @mailer.build_resend_params(message)
    expect(body[:from]).to eql("test@example.com")
    expect(body[:to]).to eql(["test@example.org"])
    expect(body[:html]).to be nil
    expect(body[:text]).to eql("text")
  end

  it "properly creates a html text with attachments msg" do
    message = TestMailer.with_attachment("test@example.org", "Test!")
    body = @mailer.build_resend_params(message)
    expect(body[:from]).to eql("test@example.com")
    expect(body[:to]).to eql(["test@example.org"])
    expect(body[:html]).to eql("<p>html</p>")
    expect(body[:text]).to eql("txt")
    expect(body[:attachments].length).to eql(1)
    expect(body[:attachments].first[:filename]).to eql("invoice.pdf")
    expect(body[:attachments].first[:content].length > 0).to be true
  end

  it "properly handles from display name" do
    message = TestMailerWithDisplayName
      .text_only("test@example.org", "Test!")

    body = @mailer.build_resend_params(message)
    expect(body[:from]).to eql("Test <test@example.com>")
    expect(body[:to]).to eql(["test@example.org"])
    expect(body[:html]).to be nil
    expect(body[:text]).to eql("text")
  end
end
