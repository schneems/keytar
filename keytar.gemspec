# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{keytar}
  s.version = "1.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Schneems"]
  s.date = %q{2011-07-13}
  s.description = %q{
    Keytar is a Ruby on Rails wrapper for KeyBuilder.
    Use KeyBuilder to automatically generate keys based on class name instead of cluttering model
    definitions with tons of redundant key method declarations.
  }
  s.email = %q{richard.schneeman@gmail.com}
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".autotest",
    ".rspec",
    ".rvmrc",
    "Gemfile",
    "README.md",
    "Rakefile",
    "VERSION",
    "autotest/discover.rb",
    "keytar.gemspec",
    "lib/.DS_Store",
    "lib/keytar.rb",
    "lib/keytar/key_builder.rb",
    "license.txt",
    "spec/keytar/key_builder_spec.rb",
    "spec/keytar/keytar_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/Schnems/keytar}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A crazy simple library for building keys  (in _key_ value store, not house keys) for Ruby on Rails}
  s.test_files = [
    "spec/keytar/key_builder_spec.rb",
    "spec/keytar/keytar_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_development_dependency(%q<activerecord>, ["~> 3.0.4"])
      s.add_development_dependency(%q<rake>, ["~> 0.8.7"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<autotest-standalone>, [">= 0"])
      s.add_development_dependency(%q<autotest-growl>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<activerecord>, ["~> 3.0.4"])
      s.add_dependency(%q<rake>, ["~> 0.8.7"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<autotest-standalone>, [">= 0"])
      s.add_dependency(%q<autotest-growl>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<activerecord>, ["~> 3.0.4"])
    s.add_dependency(%q<rake>, ["~> 0.8.7"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<autotest-standalone>, [">= 0"])
    s.add_dependency(%q<autotest-growl>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end

