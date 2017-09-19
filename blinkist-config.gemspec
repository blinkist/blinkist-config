
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative "lib/blinkist/config/version"

Gem::Specification.new do |spec|
  spec.name          = "blinkist-config"
  spec.version       = Blinkist::Config::VERSION
  spec.authors       = ["Sebastian Schleicher, Blinks Labs GmbH"]
  spec.email         = ["sj@blinkist.com"]

  spec.summary       = "Simple adapter based configuration handler (supports ENV and Consul/Diplomat)."
  spec.description   = "This GEM allows you to keep your configuration class-based by calling Blinkist::Config.get(...) instead of accessing the ENV directly. You can set up different types of adapters to connect to various configuration systems like your ENV or Consul's key-value-store."
  spec.homepage      = "https://github.com/blinkist/blinkist-config"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = %w[lib]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency "diplomat", "~> 1"
end
