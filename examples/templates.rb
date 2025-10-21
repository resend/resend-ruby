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

# Get a template by ID
retrieved_template = Resend::Templates.get(template[:id])
puts "\nRetrieved template by ID: #{retrieved_template[:id]}"
puts "Template name: #{retrieved_template[:name]}"
puts "Template status: #{retrieved_template[:status]}"
puts "Template HTML: #{retrieved_template[:html]}"

# Get a template by alias
retrieved_by_alias = Resend::Templates.get("complete")
puts "\nRetrieved template by alias: #{retrieved_by_alias[:alias]}"
puts "Template ID: #{retrieved_by_alias[:id]}"
puts "Template from: #{retrieved_by_alias[:from]}"
puts "Template subject: #{retrieved_by_alias[:subject]}"

if retrieved_by_alias[:variables] && !retrieved_by_alias[:variables].empty?
  puts "Template variables:"
  retrieved_by_alias[:variables].each do |var|
    # Use string keys for nested objects
    puts "  - #{var['key']} (#{var['type']}): #{var['fallback_value']}"
  end
end

# Update a template by ID
update_params = {
  name: "updated-welcome-email",
  html: "<h1>Welcome!</h1><p>We're glad you're here, {{{NAME}}}!</p>",
  variables: [
    {
      key: "NAME",
      type: "string",
      fallback_value: "friend"
    }
  ]
}

updated_template = Resend::Templates.update(template[:id], update_params)
puts "\nUpdated template: #{updated_template[:id]}"

# Verify the update by retrieving it again
verified = Resend::Templates.get(template[:id])
puts "Updated template name: #{verified[:name]}"
puts "Updated template HTML: #{verified[:html]}"

# Update a template by alias
alias_update_params = {
  subject: "Welcome to Acme - Updated",
  from: "Acme Team <team@resend.dev>"
}

updated_by_alias = Resend::Templates.update("complete", alias_update_params)
puts "\nUpdated template by alias: #{updated_by_alias[:id]}"
