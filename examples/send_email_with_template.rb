# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

template_params = {
  name: "welcome-notification",
  alias: "welcome",
  from: "Acme <onboarding@resend.dev>",
  subject: "Welcome to Acme, {{{name}}}!",
  reply_to: "support@resend.dev",
  html: "<h1>Hello {{{name}}} {{{surname}}}!</h1><p>You are {{{age}}} years old.</p>",
  text: "Hello {{{name}}} {{{surname}}}!\n\nYou are {{{age}}} years old.",
  variables: [
    {
      key: "name",
      type: "string",
      fallback_value: "John"
    },
    {
      key: "surname",
      type: "string",
      fallback_value: "Doe"
    },
    {
      key: "age",
      type: "number",
      fallback_value: 25
    }
  ]
}

template = Resend::Templates.create(template_params)
puts "Created template: #{template[:id]}"
puts

puts "Publishing the template..."
published = Resend::Templates.publish(template[:id])
puts "Published template: #{published[:id]}"
puts

puts "Sending email with template (using fallback values)..."
email_params_simple = {
  from: "onboarding@resend.dev",
  to: ["delivered@resend.dev"],
  template: {
    id: template[:id]
  }
}

email_simple = Resend::Emails.send(email_params_simple)
puts "Sent email: #{email_simple[:id]}"
puts

puts "Sending email with template and custom variables..."
email_params = {
  from: "onboarding@resend.dev",
  to: ["delivered@resend.dev"],
  template: {
    id: template[:id],
    variables: {
      name: "Alice",
      surname: "Smith",
      age: 30
    }
  }
}

email = Resend::Emails.send(email_params)
puts "Sent email: #{email[:id]}"
puts

puts "Sending batch emails with template..."
batch_params = [
  {
    from: "onboarding@resend.dev",
    to: ["user1@resend.dev"],
    template: {
      id: template[:id],
      variables: {
        name: "Bob",
        surname: "Johnson",
        age: 25
      }
    }
  },
  {
    from: "onboarding@resend.dev",
    to: ["user2@resend.dev"],
    template: {
      id: template[:id],
      variables: {
        name: "Carol",
        surname: "Williams",
        age: 35
      }
    }
  }
]

batch_emails = Resend::Batch.send(batch_params)
puts "Sent batch emails:"
batch_emails[:data].each do |email_data|
  puts "  - #{email_data['id']}"
end
puts

puts "Sending email using template alias..."
email_with_alias = {
  from: "onboarding@resend.dev",
  to: ["delivered@resend.dev"],
  template: {
    id: "welcome",  # Using alias instead of UUID
    variables: {
      name: "Dave",
      surname: "Brown",
      age: 40
    }
  }
}

email_alias = Resend::Emails.send(email_with_alias)
puts "Sent email using alias: #{email_alias[:id]}"
puts

puts "Cleaning up..."
removed = Resend::Templates.remove(template[:id])
puts "Removed template: #{removed[:id]} (Deleted: #{removed[:deleted]})"
puts

puts "=== Example completed successfully! ==="
