# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'
require 'factories/scopes_model'

RSpec.describe GroupScopeModel do
  before do
    3.times { |i| FactoryBot.create(:ScopesModel, name: "group-a-#{i}", position: i, group: 'a') }
    3.times { |i| FactoryBot.create(:ScopesModel, name: "group-b-#{i}", position: i, group: 'b') }
  end

  let(:a_names) { GroupScopeModel.where(group: 'a').order(:position).pluck(:name) }
  let(:a_positions) { GroupScopeModel.where(group: 'a').order(:position).pluck(:position) }

  let(:b_names) { GroupScopeModel.where(group: 'b').order(:position).pluck(:name) }
  let(:b_positions) { GroupScopeModel.where(group: 'b').order(:position).pluck(:position) }

  context 'when creating a new record to scope' do
    before { GroupScopeModel.create(name: 'group-a-3', position: 0, group: 'a', kind: 'omega') }

    it 'pushes later positions in scope' do
      expect(a_names).to eq(%w[group-a-3 group-a-0 group-a-1 group-a-2])
    end

    it 'keeps the sequential order in scope' do
      expect(a_positions).to eq((0..3).to_a)
    end

    it 'dont affect positions in other scopes' do
      expect(b_names).to eq(%w[group-b-0 group-b-1 group-b-2])
      expect(b_positions).to eq((0..2).to_a)
    end
  end

  context 'when updating to a higher position in scope' do
    before { GroupScopeModel.find_by(name: 'group-b-0').update(position: 2) }

    it 'shifts objects around' do
      expect(b_names).to eq(%w[group-b-1 group-b-2 group-b-0])
    end

    it 'keeps the sequential order' do
      expect(b_positions).to eq((0..2).to_a)
    end

    it 'dont affect positions in other scopes' do
      expect(a_names).to eq(%w[group-a-0 group-a-1 group-a-2])
      expect(a_positions).to eq((0..2).to_a)
    end
  end

  context 'when updating to a lower position in scope' do
    before { GroupScopeModel.find_by(name: 'group-a-2').update(position: 0) }

    it 'shifts objects around' do
      expect(a_names).to eq(%w[group-a-2 group-a-0 group-a-1])
    end

    it 'keeps the sequential order' do
      expect(a_positions).to eq((0..2).to_a)
    end

    it 'dont affect positions in other scopes' do
      expect(b_names).to eq(%w[group-b-0 group-b-1 group-b-2])
      expect(b_positions).to eq((0..2).to_a)
    end
  end

  context 'when destroying a record in scope' do
    before { GroupScopeModel.find_by(name: 'group-b-1').destroy }

    it 'pulls all later positions' do
      expect(b_names).to eq(%w[group-b-0 group-b-2])
    end

    it 'keeps the sequential order' do
      expect(b_positions).to eq((0..1).to_a)
    end

    it 'dont affect positions in other scopes' do
      expect(a_names).to eq(%w[group-a-0 group-a-1 group-a-2])
      expect(a_positions).to eq((0..2).to_a)
    end
  end
end
