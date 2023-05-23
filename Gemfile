# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "ammeter", "~> 1.1.5"
gem "rake", "~> 13.0"
gem "standalone_migrations", "~> 6.1"

group :test do
  gem "database_cleaner-active_record", "~> 2.0", ">= 2.0.1"
  gem "factory_bot_rails", "~> 6.2"
  gem "rspec", "~> 3.0"
  gem "shoulda-matchers", "~> 5.1.0"
end

group :test, :development do
  gem "byebug", "~> 11.1.3"
  gem "pg", "~> 1.4.3"
  gem "rubocop", "~> 0.80"
end
