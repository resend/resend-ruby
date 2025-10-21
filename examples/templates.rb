# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

# Create a simple template
simple_params = {
  name: "welcome-email",
  html: "<strong>Welcome to our platform!</strong>"
}

template = Resend::Templates.create(simple_params)
puts "Created template: #{template[:id]}"

# Create a template with variables
template_with_vars = {
  name: "personalized-welcome",
  html: "<strong>Hey, {{{NAME}}}, you are {{{AGE}}} years old.</strong>",
  variables: [
    {
      key: "NAME",
      type: "string",
      fallback_value: "user"
    },
    {
      key: "AGE",
      type: "number",
      fallback_value: 25
    },
    {
      key: "OPTIONAL_VARIABLE",
      type: "string"
    }
  ]
}

template_advanced = Resend::Templates.create(template_with_vars)
puts "Created template with variables: #{template_advanced[:id]}"

# Create a complete template with all optional fields
complete_params = {
  name: "complete-template",
  alias: "complete",
  from: "Acme <onboarding@resend.dev>",
  subject: "Welcome to Acme",
  reply_to: "support@resend.dev",
  html: "<h1>Hello {{{FIRST_NAME}}} {{{LAST_NAME}}}</h1><p>Welcome to our platform!</p>",
  text: "Hello {{{FIRST_NAME}}} {{{LAST_NAME}}}\n\nWelcome to our platform!",
  variables: [
    {
      key: "FIRST_NAME",
      type: "string",
      fallback_value: "John"
    },
    {
      key: "LAST_NAME",
      type: "string",
      fallback_value: "Doe"
    }
  ]
}

complete_template = Resend::Templates.create(complete_params)
puts "Created complete template: #{complete_template[:id]}"
puts "Template object type: #{complete_template[:object]}"
