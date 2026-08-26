# frozen_string_literal: true

require "resend"
require "resend/action_mailbox/message_builder"
require "resend/action_mailbox/engine" if defined?(::Rails::Engine)
