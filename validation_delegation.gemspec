# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "validation_delegation/version"

Gem::Specification.new do |spec|
  spec.name          = "validation_delegation"
  spec.version       = ValidationDelegation::VERSION
  spec.authors       = ["Ben Eddy"]
  spec.email         = ["bae@foraker.com"]
  spec.description   = %q{Delegates validation between objects}
  spec.summary       = %q{Validation delegation allows an object to proxy validations to other objects. This facilitates composition and prevents the duplication of validation logic.}
  spec.homepage      = "https://github.com/foraker/validation_delegation"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 3.1"
  spec.add_dependency "activemodel", ">= 3.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
