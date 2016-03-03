# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy_json_schema/version'

Gem::Specification.new do |spec|
  spec.name          = "easy_json_schema"
  spec.version       = EasyJsonSchema::VERSION
  spec.authors       = ["Nick Donataccio"]
  spec.email         = ["ndonataccio@handy.com"]

  spec.summary       = "Easy interface to loading and using json schema files"
  spec.description   = "Easy interface to loading and using json schema files"
  spec.homepage      = "https://github.com/ndonataccio-handy/easy_json_schema"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
#  if spec.respond_to?(:metadata)
#    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
#  else
#    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
#  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"

  spec.add_runtime_dependency "json-schema", "~> 2.6.1"
  spec.add_runtime_dependency "prmd", "~> 0.11.4"
end
