# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'
require 'factories/basic_model'

RSpec.describe 'Configuration option :validate', :with_validations do
  before { create_list(:basic_model, 2) }

  context 'when validate option is set to true' do
    subject { build(:basic_model) }

    it { should validate_presence_of(:position) }
    it { should validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0) }

    describe 'validates that :position is less or equal to its current maximum possible value' do
      context 'when model is persisted' do
        subject { create(:basic_model, name: 'c', position: 2) }

        it { should allow_values(*(0..2)).for(:position) }
        it { should_not allow_values(-1, 3).for(:position) }
      end

      context 'when model is not persisted' do
        subject { build(:basic_model, name: 'c', position: 2) }

        it { should allow_values(*(0..2)).for(:position) }
        it { should_not allow_values(-1, 3).for(:position) }
      end
    end
  end

  context 'when validate option is set to false' do
    subject { build(:no_validation_model, name: 'c', position: 2) }

    it { should_not validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0) }

    describe 'doesn\'t validate that :position is less or equal to its current maximum possible value' do
      context 'when model is persisted' do
        subject { create(:no_validation_model, name: 'c', position: 2) }

        it { should allow_values(*(-1..3)).for(:position) }
      end

      context 'when model is not persisted' do
        subject { build(:no_validation_model, name: 'c', position: 2) }

        it { should allow_values(*(-1..3)).for(:position) }
      end
    end
  end
end
