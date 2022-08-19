# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'

RSpec.describe 'Validation', type: :model do
  context 'when validate option is set to true' do
    subject { BasicModel.new(name: 'a', position: 0) }

    it { should validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0) }
    
    describe 'validates that :position is less or equal to its current maximum possible value' do
      before do
        BasicModel.insert_all([
          { name: 'a', position: 0 },
          { name: 'b', position: 1 }
        ])
      end

      context 'when model is persisted' do
        subject { BasicModel.create(name: 'c', position: 2) }

        it { should allow_values(*(0..2)).for(:position) }
        it { should_not allow_values(-1, 3).for(:position)}
      end

      context 'when model is not persisted' do
        subject { BasicModel.new(name: 'c', position: 2) }

        it { should allow_values(*(0..2)).for(:position) }
        it { should_not allow_values(-1, 3).for(:position)}
      end
    end
  end

  context 'when validate option is set to false' do
    subject { NoValidationModel.new(name: 'c', position: 2) }

    it { should_not validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0) }
    
    describe 'doesn\'t validate that :position is less or equal to its current maximum possible value' do
      before do
        NoValidationModel.insert_all([
          { name: 'a', position: 0 },
          { name: 'b', position: 1 }
        ])
      end

      context 'when model is persisted' do
        subject { NoValidationModel.create(name: 'c', position: 2) }

        it { should allow_values(*(-1..3)).for(:position) }
      end

      context 'when model is not persisted' do
        subject { NoValidationModel.new(name: 'c', position: 2) }

        it { should allow_values(*(-1..3)).for(:position) }
      end
    end
  end
end
