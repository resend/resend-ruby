# frozen_string_literal: true

require "resend"
require "resend/mailer"

module Resend
  # Main railtime class
  class Railtie < ::Rails::Railtie
    ActiveSupport.on_load(:action_mailer) do
      add_delivery_method :resend, Resend::Mailer
      ActiveSupport.run_load_hooks(:resend_mailer, Resend::Mailer)
    end
  end
end
