require 'support/database_helper'
require 'support/models'

RSpec.describe BasicModel do
  subject { BasicModel.create!(name: 'subject', position: 0) }
  let(:second_model) { BasicModel.create!(name: 'basic_model', position: 0) }

  before do
    Addon.insert_all([

      { name: 'a', position: 0, basic_model_id: second_model.id },
      { name: 'b', position: 1, basic_model_id: second_model.id },
      { name: 'c', position: 2, basic_model_id: second_model.id },
      { name: 'd', position: 3, basic_model_id: second_model.id },
      { name: 'e', position: 0, basic_model_id: subject.id },
      { name: 'f', position: 1, basic_model_id: subject.id },
      { name: 'g', position: 2, basic_model_id: subject.id },
      { name: 'h', position: 3, basic_model_id: subject.id },
    ])
  end

  let(:names) { subject.addons.order(:position).pluck(:name) }
  let(:positions) { subject.addons.order(:position).pluck(:position) }
  let(:second_model_names) { second_model.addons.order(:position).pluck(:name) }
  let(:second_model_positions) { second_model.addons.order(:position).pluck(:position) }

  context 'when creating a new record to scope' do
    before { subject.addons.create(name: 'i', position: 1) }

    it 'pushes later positions in scope' do
      expect(names).to eq(%w[e i f g h])
    end

    it 'keeps the sequential order in scope' do
      expect(positions).to eq((0..4).to_a)
    end

    it 'dont affect positions in other scopes' do
      expect(second_model_names).to eq(%w[a b c d])
      expect(second_model_positions).to eq((0..3).to_a)
    end
  end
  
  context 'when updating to a higher position in scope' do
    before { subject.addons.find_by(name: 'e').update(position: 2) }

    it 'shifts objects around' do
      expect(names).to eq(%w[f g e h])
    end

    it 'keeps the sequential order' do
      expect(positions).to eq((0..3).to_a)
    end
    
    it 'dont affect positions in other scopes' do
      expect(second_model_names).to eq(%w[a b c d])
      expect(second_model_positions).to eq((0..3).to_a)
    end
  end
  
  context 'when updating to a lower position in scope' do
    before { subject.addons.find_by(name: 'h').update(position: 1) }

    it 'shifts objects around' do
      expect(names).to eq(%w[e h f g])
    end

    it 'keeps the sequential order' do
      expect(positions).to eq((0..3).to_a)
    end

    it 'dont affect positions in other scopes' do
      expect(second_model_names).to eq(%w[a b c d])
      expect(second_model_positions).to eq((0..3).to_a)
    end
  end
  
  context 'when destroying a record' do
    before { subject.addons.find_by(name: 'f').destroy }

    it 'pulls all later positions' do
      expect(names).to eq(%w[e g h])
    end

    it 'keeps the sequential order' do
      expect(positions).to eq((0..2).to_a)
    end
    
    it 'dont affect positions in other scopes' do
      expect(second_model_names).to eq(%w[a b c d])
      expect(second_model_positions).to eq((0..3).to_a)
    end
  end
end
