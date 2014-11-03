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
  spec.summary       = %q{Delegates validation between objects}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 4.1.0"
  spec.add_dependency "activemodel", "~> 4.1.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
