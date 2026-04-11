# frozen_string_literal: true

require_relative "../lib/resend"

raise if ENV["RESEND_API_KEY"].nil?

Resend.api_key = ENV["RESEND_API_KEY"]

# 1. Create a template (needed for the send_email step config)
template = Resend::Templates.create({
  name: "Welcome Email",
  from: "onboarding@resend.dev",
  subject: "Welcome!",
  html: "<p>Welcome to our platform!</p>"
})
template_id = template[:id]
puts "created template: #{template_id}"

Resend::Templates.publish(template_id)
puts "published template: #{template_id}"

# 2. Create a simple automation: trigger → send_email
simple_automation = Resend::Automations.create({
  name: "Simple Welcome Automation",
  steps: [
    {
      key: "trigger",
      type: "trigger",
      config: { event_name: "user.created" }
    },
    {
      key: "send_welcome",
      type: "send_email",
      config: { template: { id: template_id } }
    }
  ],
  connections: [
    { from: "trigger", to: "send_welcome", type: "default" }
  ]
})
automation_id = simple_automation[:id]
puts "created simple automation: #{automation_id}"

# 3. Get automation
retrieved = Resend::Automations.get(automation_id)
puts "retrieved automation: #{retrieved[:id]}, status: #{retrieved[:status]}"

# 4. Update automation (change status to enabled)
updated = Resend::Automations.update({
  automation_id: automation_id,
  status: "enabled"
})
puts "updated automation: #{updated[:id]}"

# 5. List automations (without filter)
all_automations = Resend::Automations.list
puts "automations: #{all_automations[:data].length}, has_more: #{all_automations[:has_more]}"

# List automations with status filter
enabled_automations = Resend::Automations.list({ status: "enabled" })
puts "enabled automations: #{enabled_automations[:data].length}"

# 6. Stop automation
stopped = Resend::Automations.stop(automation_id)
puts "stopped automation: #{stopped[:id]}"

# 7. List runs (Resend::Automations::Runs.list)
runs = Resend::Automations::Runs.list(automation_id)
puts "runs: #{runs[:data].length}, has_more: #{runs[:has_more]}"

# 8. Get a run if any exist (Resend::Automations::Runs.get)
if runs[:data].any?
  run_id = runs[:data].first[:id]
  run = Resend::Automations::Runs.get(automation_id, run_id)
  puts "run: #{run[:id]}, status: #{run[:status]}"
else
  puts "no runs yet for this automation"
end

# 9. Multi-step automation: trigger → delay → wait_for_event → send_email
multi_automation = Resend::Automations.create({
  name: "Multi-step Onboarding Automation",
  steps: [
    {
      key: "trigger",
      type: "trigger",
      config: { event_name: "user.created" }
    },
    {
      key: "wait_30_min",
      type: "delay",
      config: { duration: "30 minutes" }
    },
    {
      key: "wait_verified",
      type: "wait_for_event",
      config: { event_name: "user.verified", timeout: "1 hour" }
    },
    {
      key: "send_welcome",
      type: "send_email",
      config: { template: { id: template_id } }
    }
  ],
  connections: [
    { from: "trigger", to: "wait_30_min", type: "default" },
    { from: "wait_30_min", to: "wait_verified", type: "default" },
    { from: "wait_verified", to: "send_welcome", type: "event_received" }
  ]
})
multi_automation_id = multi_automation[:id]
puts "created multi-step automation: #{multi_automation_id}"

# 10. Cleanup: delete both automations and the template
Resend::Automations.remove(automation_id)
puts "removed automation: #{automation_id}"

Resend::Automations.remove(multi_automation_id)
puts "removed multi-step automation: #{multi_automation_id}"

Resend::Templates.remove(template_id)
puts "removed template: #{template_id}"
