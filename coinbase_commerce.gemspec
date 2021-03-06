
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "coinbase_commerce/version"

Gem::Specification.new do |spec|
  spec.name          = "coinbase_commerce"
  spec.version       = CoinbaseCommerce::VERSION
  spec.authors       = ["Siddharth Sharma"]
  spec.email         = ["siddharth10104737@gmail.com"]
  spec.summary       = %q{CoinbaseCommerce is an API wrapper for CoinbaseCommerce's API (https://commerce.coinbase.com/docs/api).}
  spec.description   = spec.summary
  spec.homepage      = "http://github.com/vinsol/coinbase_commerce"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty"
  spec.add_dependency "multi_json"
  spec.add_dependency 'recursive-open-struct'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
