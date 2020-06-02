require_relative 'lib/webpacker/pwa/version'

Gem::Specification.new do |spec|
  spec.name          = "webpacker-pwa"
  spec.version       = Webpacker::Pwa::VERSION
  spec.authors       = ["Alessandro Rodi"]
  spec.email         = ["alessandro.rodi@renuo.ch"]

  spec.summary       = %q{webpacker-pwa enables you to serve service workers with webpack-dev-server}
  spec.homepage      = "https://github.com/coorasse/webpacker-pwa"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/coorasse/webpacker-pwa"
  spec.metadata["changelog_uri"] = "https://github.com/coorasse/webpacker-pwa/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rack-proxy",    ">= 0.6.1"
  spec.add_dependency "webpacker",    ">= 4.0.0"
end
