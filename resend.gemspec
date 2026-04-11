# frozen_string_literal: true

require_relative "lib/resend/version"

Gem::Specification.new do |spec|
  spec.name          = "resend"
  spec.version       = Resend::VERSION
  spec.summary       = "The Ruby and Rails SDK for resend.com"
  spec.homepage      = "https://github.com/resend/resend-ruby"
  spec.license       = "MIT"

  spec.author        = "Derich Pacheco"
  spec.email         = "carlosderich@gmail.com"

  spec.files         = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path  = "lib"
  spec.required_ruby_version = ">= 3.2"
  spec.add_dependency "base64"
  spec.add_dependency "httparty", ">= 0.22.0"
end
