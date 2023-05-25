# frozen_string_literal: true

require_relative "lib/orderable/version"

Gem::Specification.new do |spec|
  spec.name          = "orderable"
  spec.version       = Orderable::VERSION
  spec.authors       = ["Piotr Kruczek"]
  spec.email         = ["piotr.kruczek@ventcode.com"]

  spec.summary       = "Orderable summary"
  # spec.description   = "TODO: Write a longer description or delete this line."
  spec.homepage      = "https://ventcode.com"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

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

  spec.add_dependency "activerecord", ">= 6.0"
  spec.add_dependency "rake", "~> 13.0"
  spec.add_development_dependency "ammeter", "~> 1.1.5"
  spec.add_development_dependency "byebug", "~> 11.1.3"
  spec.add_development_dependency "database_cleaner-active_record", "~> 2.0", ">= 2.0.1"
  spec.add_development_dependency "factory_bot_rails", "~> 6.2"
  spec.add_development_dependency "pg", "~> 1.4.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.80"
  spec.add_development_dependency "shoulda-matchers", "~> 5.1.0"
  spec.add_development_dependency "standalone_migrations", "~> 6.1"
end
