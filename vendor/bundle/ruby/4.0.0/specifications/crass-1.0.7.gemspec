# -*- encoding: utf-8 -*-
# stub: crass 1.0.7 ruby lib

Gem::Specification.new do |s|
  s.name = "crass".freeze
  s.version = "1.0.7".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/rgrove/crass/issues", "changelog_uri" => "https://github.com/rgrove/crass/blob/v1.0.7/HISTORY.md", "documentation_uri" => "https://www.rubydoc.info/gems/crass/1.0.7", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/rgrove/crass/tree/v1.0.7" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ryan Grove".freeze]
  s.date = "1980-01-02"
  s.description = "Crass is a pure Ruby CSS parser based on the CSS Syntax Level 3 spec.".freeze
  s.email = ["ryan@wonko.com".freeze]
  s.homepage = "https://github.com/rgrove/crass/".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2".freeze)
  s.rubygems_version = "4.0.10".freeze
  s.summary = "CSS parser based on the CSS Syntax Level 3 spec.".freeze

  s.installed_by_version = "4.0.16".freeze

  s.specification_version = 4

  s.add_development_dependency(%q<minitest>.freeze, ["~> 6.0.6".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.4.2".freeze])
end
