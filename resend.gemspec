# frozen_string_literal: true

require_relative "lib/resend/version"

Gem::Specification.new do |spec|
  spec.name          = "resend"
  spec.version       = Resend::VERSION
  spec.summary       = "The Ruby and Rails SDK for resend.com"
  spec.homepage      = "https://github.com/resendlabs/resend-ruby"
  spec.license       = "MIT"

  spec.author        = "Derich Pacheco"
  spec.email         = "carlosderich@gmail.com"

  spec.files         = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path  = "lib"
  spec.required_ruby_version = ">= 2.6"
  spec.add_dependency "httparty", ">= 0.19.1"
  spec.add_development_dependency "rails"
end
