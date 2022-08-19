# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'

RSpec.describe 'Validation', type: :model do
  context 'when validate option is set to true' do
    before do
      BasicModel.insert_all([
        { name: 'a', position: 0 },
        { name: 'b', position: 1 }
      ])
    end

    subject { BasicModel.new(name: 'c', position: 2) }

    it { should validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0) }
    it 'validates that :position is less or equal to its current maximum possible value' do
      expect(subject).to be_valid

      subject.position = 3
      expect(subject).to be_invalid

      subject.position = 1
      expect(subject).to be_valid

      subject.save

      subject.position = 2
      expect(subject).to be_valid

      subject.position = 3
      expect(subject).to be_invalid

      subject.position = 1
      expect(subject).to be_valid
    end
  end

  context 'when validate option is set to false' do
    before do
      NoValidationModel.insert_all([
        { name: 'a', position: 0 },
        { name: 'b', position: 1 }
      ])
    end

    subject { NoValidationModel.new(name: 'c', position: 2) }

    it { should_not validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0) }
    it "doesn't validate that :position is less or equal to its current maximum possible value" do
      subject.position = 3
      expect(subject).to be_valid

      subject.save

      subject.position = 3
      expect(subject).to be_valid
    end
  end
end
