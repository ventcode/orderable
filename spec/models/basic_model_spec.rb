# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'

RSpec.describe BasicModel do
  before do
    BasicModel.insert_all([
                            { name: 'a', position: 0 },
                            { name: 'b', position: 1 },
                            { name: 'c', position: 2 },
                            { name: 'd', position: 3 }
                          ])
  end

  let(:names) { BasicModel.order(:position).pluck(:name) }
  let(:positions) { BasicModel.order(:position).pluck(:position) }

  context 'when creating a new record' do
    before { BasicModel.create(name: 'e', position: 2) }

    it 'pushes all later positions' do
      expect(names).to eq(%w[a b e c d])
    end

    it 'keeps the sequential order' do
      expect(positions).to eq((0..4).to_a)
    end
  end

  context 'when updating to a higher position' do
    before { described_class.find_by(name: 'a').update(position: 2) }

    it 'shifts objects around' do
      expect(names).to eq(%w[b c a d])
    end

    it 'keeps the sequential order' do
      expect(positions).to eq((0..3).to_a)
    end
  end

  context 'when updating to a lower position' do
    before { described_class.find_by(name: 'c').update(position: 0) }

    it 'shifts objects around' do
      expect(names).to eq(%w[c a b d])
    end

    it 'keeps the sequential order' do
      expect(positions).to eq((0..3).to_a)
    end
  end

  context 'when destroying a record' do
    before { described_class.find_by(name: 'c').destroy }

    it 'pulls all later positions' do
      expect(names).to eq(%w[a b d])
    end

    it 'keeps the sequential order' do
      expect(positions).to eq((0..2).to_a)
    end
  end
end
