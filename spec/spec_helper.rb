# frozen_string_literal: true

require "simplecov"
require "byebug"
require "fixtures"
require "orderable"
require "database_cleaner/active_record"
require "shoulda-matchers"
require "factory_bot_rails"
require "ammeter/init"
require "rspec-benchmark"
require "benchmark"
require_relative "./factories"
Dir["./support/*.rb"].sort.each { |file| require file }

SimpleCov.start do
  formatter SimpleCov::Formatter::SimpleFormatter
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    FactoryBot.reload
  end

  unless ENV["SPEC_DISABLE_DROP_DATABASE"] == "1"
    config.after(:suite) do
      Rake::Task["db:drop"].invoke
    end
  end

  config.before(:suite) do
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.include(Shoulda::Matchers::ActiveModel, :with_validations)
  config.include(Shoulda::Matchers::ActiveRecord, :with_validations)
  config.include FactoryBot::Syntax::Methods
  config.include RSpec::Benchmark::Matchers
end

RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_record
    with.library :active_model
  end
end

def elapsed_time(&block)
  Benchmark.measure do
    block.call
  end.real
end
