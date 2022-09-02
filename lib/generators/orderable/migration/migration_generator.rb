# frozen_string_literal: true

require 'rails/generators/base'
require 'rails/generators/active_record/migration'

module Orderable
  module Generators
    class MigrationGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      argument :arguments, type: :string, banner: 'table:field'

      source_root File.expand_path('templates', __dir__)

      def create_migration_file
        set_local_assigns!
        migration_template 'migration.rb', File.join(db_migrate_path, "#{file_name}.rb")
      end

      private

      attr_reader :field_name, :file_name, :table_name

      def set_local_assigns!
        @table_name, @field_name = deconstruct_argument
        @file_name = "add_unique_orderable_#{field_name}_to_#{table_name.singularize}"
      end

      def deconstruct_argument
        table, field = arguments.split(':')
        [normalize_table_name(table).underscore, field.underscore]
      end

      def normalize_table_name(table_name)
        pluralize_table_names? ? table_name.pluralize : table_name.singularize
      end

      def pluralize_table_names?
        !defined?(ActiveRecord::Base) || ActiveRecord::Base.pluralize_table_names
      end
    end
  end
end
