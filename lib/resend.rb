# frozen_string_literal: true

require_relative "resend/version"
require "resend/client"

require "./railsend" if defined?(Rails) && defined?(ActionMailer)
