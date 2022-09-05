# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'
require 'factories/basic_model'

RSpec.describe 'Order modification' do
  before { create_list(:basic_model, 4) }

  let(:names) { BasicModel.pluck(:name) }
  let(:positions) { BasicModel.pluck(:position) }

  context 'when creating a new record' do
    before { create(:basic_model, name: 'e', position: 2) }

    it 'pushes all later positions' do
      expect(names).to eq(%w[d c e b a])
    end

    it 'keeps the sequential order' do
      expect(positions).to eq((0..4).to_a.reverse)
    end
  end

  context 'when updating to a higher position' do
    before { BasicModel.find_by(name: 'a').update(position: 2) }

    it 'shifts objects around' do
      expect(names).to eq(%w[d a c b])
    end

    it 'keeps the sequential order' do
      expect(positions).to eq((0..3).to_a.reverse)
    end
  end

  context 'when updating to a lower position' do
    before { BasicModel.find_by(name: 'c').update(position: 0) }

    it 'shifts objects around' do
      expect(names).to eq(%w[d b a c])
    end

    it 'keeps the sequential order' do
      expect(positions).to eq((0..3).to_a.reverse)
    end
  end

  context 'when destroying a record' do
    before { BasicModel.find_by(name: 'c').destroy }

    it 'pulls all later positions' do
      expect(names).to eq(%w[d b a])
    end

    it 'keeps the sequential order' do
      expect(positions).to eq((0..2).to_a.reverse)
    end
  end
end
