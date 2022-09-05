# frozen_string_literal: true

require 'generators/orderable/migration/migration_generator'

RSpec.describe Orderable::Generators::MigrationGenerator, type: :generator do
  destination File.expand_path('../../tmp', __dir__)

  before do
    prepare_destination
    run_generator %w[BasicModel:PositionField scope scope2]
  end

  describe 'the migration' do
    subject { migration_file('db/migrate/add_unique_orderable_position_field_to_basic_model.rb') }

    it { is_expected.to exist }
    it { is_expected.to contain /execute/ }
    it { is_expected.to contain /ALTER TABLE basic_models/ }
    it { is_expected.to contain /ADD position_field INTEGER,/ }
    it { is_expected.to contain /ADD UNIQUE\(position_field, scope, scope2\) DEFERRABLE INITIALLY DEFERRED/ }
    it { is_expected.to contain /DROP COLUMN position_field/ }
  end
end
