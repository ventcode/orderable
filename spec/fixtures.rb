# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require "active_record/railtie"
require "standalone_migrations"

ActiveRecord::Base.schema_format = :sql
StandaloneMigrations::Tasks.load_tasks

config = StandaloneMigrations::Configurator.load_configurations
ActiveRecord::Base.establish_connection(config["test"])
