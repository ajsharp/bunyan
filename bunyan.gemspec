# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bunyan}
  s.version = "0.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex Sharp"]
  s.date = %q{2011-03-31}
  s.description = %q{Bunyan is a thin ruby wrapper around a MongoDB capped collection, created with high-performance, flexible logging in mind.}
  s.email = %q{ajsharp@gmail.com}
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    "CHANGELOG.md",
    "Gemfile",
    "MIT-LICENSE",
    "README.md",
    "Rakefile",
    "VERSION",
    "bunyan.gemspec",
    "examples/middleware.rb",
    "examples/rails.rb",
    "lib/bunyan.rb",
    "lib/bunyan/config.rb",
    "lib/bunyan/configurable_methods.rb",
    "spec/bunyan_spec.rb",
    "spec/config_spec.rb",
    "spec/integration_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/ajsharp/bunyan}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A MongoDB-based logging solution.}
  s.test_files = [
    "examples/middleware.rb",
    "examples/rails.rb",
    "spec/bunyan_spec.rb",
    "spec/config_spec.rb",
    "spec/integration_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mongo>, ["~> 1.2.4"])
    else
      s.add_dependency(%q<mongo>, ["~> 1.2.4"])
    end
  else
    s.add_dependency(%q<mongo>, ["~> 1.2.4"])
  end
end

