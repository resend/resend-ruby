require_relative '../lib/resend'
require "stringio"

raise if ENV["RESEND_API_KEY"].empty?

client = Resend::Client.new(ENV["RESEND_API_KEY"])

file = IO.read(File.join(File.dirname(__FILE__), '../resources/invoice.pdf'))

params = {
  "from": "team@recomendo.io",
  "to": ["carlosderich@gmail.com"],
  "text": "test",
  "subject": "test",
  "attachments": [
    "filename": "invoice.pdf",
    "content": file.bytes # make sure to use .bytes() here
  ]
}

r = client.send_email(params)
puts r