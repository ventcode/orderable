# frozen_string_literal: true

require 'tasks/standalone_migrations'

config = StandaloneMigrations::Configurator.load_configurations
db_config = config.fetch(ENV['RAILS_ENV'], 'development')

ActiveRecord::Base.establish_connection(db_config)
