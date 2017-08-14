# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opsgenie/heartbeat/version'

Gem::Specification.new do |spec|
  spec.name          = "opsgenie-heartbeat"
  spec.version       = Opsgenie::Heartbeat::VERSION
  spec.authors       = ["Dressipi"]
  spec.email         = ["wizards@dressipi.com"]

  spec.summary       = %q{OpsGenie Heartbeat version 2}
  spec.description   = %q{OpsGenie Heartbeat version 2}
  spec.homepage      = ""
  spec.license     = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
