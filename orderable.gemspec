# frozen_string_literal: true

require_relative "lib/orderable/version"

Gem::Specification.new do |spec|
  spec.name          = "orderable"
  spec.version       = Orderable::VERSION
  spec.authors       = ["Ventcode"]
  spec.email         = ["hello@ventcode.com"]

  spec.summary       = "Orderable summary"
  # spec.description   = "TODO: Write a longer description or delete this line."
  spec.homepage      = "https://ventcode.com"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.7")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 5.0.0"
  spec.add_dependency "rake", ">= 10.0"
  spec.add_development_dependency "ammeter", "~> 1.1.5"
  spec.add_development_dependency "byebug", "~> 11.1.3"
  spec.add_development_dependency "database_cleaner-active_record", "~> 1.99.0"
  spec.add_development_dependency "factory_bot_rails", "~> 4.2"
  spec.add_development_dependency "pg", "~> 1.1"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.80"
  spec.add_development_dependency "shoulda-matchers", "~> 4.1.0"
  spec.add_development_dependency "standalone_migrations", "~> 7.1.1"
end
