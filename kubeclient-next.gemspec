# frozen_string_literal: true

require_relative "lib/kubeclient_next/version"

Gem::Specification.new do |spec|
  spec.name          = "kubeclient_next"
  spec.version       = KubeclientNext::VERSION
  spec.authors       = ["Timothy Smith"]
  spec.email         = ["tsontario@gmail.com"]

  spec.summary       = "Ruby client for interacting with kubernetes clusters"
  spec.description   = "Ruby client for interacting with kubernetes clusters"
  spec.homepage      = "https://github.com/tsontario/kubeclient_next"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    %x(git ls-files -z).split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("faraday", "~> 1.6")
  # spec.add_dependency("activesupport", ">= 6.0")

  spec.add_development_dependency("byebug")
  spec.add_development_dependency("minitest", "~> 5")
  spec.add_development_dependency("minitest-reporters")
  spec.add_development_dependency("mocha", "~> 1")
  spec.add_development_dependency("rubocop")
  spec.add_development_dependency("rubocop-shopify")
  spec.add_development_dependency("simplecov")
  spec.add_development_dependency("webmock", "~> 3.0")
end
