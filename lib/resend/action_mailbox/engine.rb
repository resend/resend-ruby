# frozen_string_literal: true

require "rails/engine"

module Resend
  module ActionMailbox
    # Rails engine that routes Resend's +email.received+ webhooks to the
    # Action Mailbox ingress controller.
    class Engine < ::Rails::Engine
      initializer "resend.action_mailbox.routes" do |app|
        app.routes.append do
          post "/rails/action_mailbox/resend/inbound_emails",
               to: "action_mailbox/ingresses/resend/inbound_emails#create",
               as: :rails_resend_inbound_emails
        end
      end
    end
  end
end
