# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hermod/version'

Gem::Specification.new do |spec|
  spec.name          = "hermod"
  spec.version       = Hermod::VERSION
  spec.authors       = ["Harry Mills"]
  spec.email         = ["harry@freeagent.com"]
  spec.summary       = %q{A Ruby library for talking to the HMRC Government Gateway.}
  spec.description   = %q{A Ruby library for talking to the HMRC Government Gateway.
  This provides a builder for creating classes that can generate the XML needed complete with type information and
  runtime validation.}
  spec.homepage      = "https://github.com/fac/hermod"
  spec.license       = "Apache License, Version 2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_runtime_dependency "libxml-ruby", "~> 3.2"
  spec.add_runtime_dependency "activesupport", "> 3.2", "< 7"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "13.0.1"
  spec.add_development_dependency "minitest", "~> 5.3"
  spec.add_development_dependency "minitest-reporters", "~> 1.0", ">= 1.0.16"
  spec.add_development_dependency "nokogiri", "~> 1.5"

  spec.metadata = {
    "allowed_push_host" => "https://rubygems.org",
    "bug_tracker_uri"   => "https://github.com/fac/hermod/issues",
    "changelog_uri"     => "https://github.com/fac/hermod/blob/master/CHANGELOG.md",
    "source_code_uri"   => "https://github.com/fac/hermod",
    "wiki_uri"          => "https://github.com/fac/hermod/blob/master/README.md"
  }
end
