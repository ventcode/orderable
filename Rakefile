# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'

RuboCop::RakeTask.new

require 'standalone_migrations'

ActiveRecord::Base.schema_format = :sql

StandaloneMigrations::Tasks.load_tasks


# task default: %i[spec rubocop]
