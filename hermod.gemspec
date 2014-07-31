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
  spec.homepage      = ""
  spec.license       = "Apache License, Version 2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2"

  spec.add_runtime_dependency "libxml-ruby", "~> 2.7", ">= 2.7.0"
  spec.add_runtime_dependency "activesupport", "~> 4.1", ">= 4.1.4"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.3", ">= 10.3.2"
  spec.add_development_dependency "minitest", "~> 5.3", ">= 5.3.5"
  spec.add_development_dependency "nokogiri", "~> 1.6", ">= 1.6.2.1"
end
