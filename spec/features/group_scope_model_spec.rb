# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'

RSpec.describe GroupScopeModel do
  before do
    GroupScopeModel.insert_all([
      { name: 'a-alpha', position: 0, group: 'a', kind: 'alpha' },
      { name: 'a-beta',  position: 1, group: 'a', kind: 'beta' },
      { name: 'a-gamma', position: 2, group: 'a', kind: 'gamma' },
      { name: 'b-alpha', position: 0, group: 'b', kind: 'alpha' },
      { name: 'b-beta',  position: 1, group: 'b', kind: 'beta' },
      { name: 'b-gamma', position: 2, group: 'b', kind: 'gamma' }
    ])
  end

  let(:a_names) { GroupScopeModel.where(group: 'a').order(:position).pluck(:name) }
  let(:a_positions) { GroupScopeModel.where(group: 'a').order(:position).pluck(:position) }

  let(:b_names) { GroupScopeModel.where(group: 'b').order(:position).pluck(:name) }
  let(:b_positions) { GroupScopeModel.where(group: 'b').order(:position).pluck(:position) }

  context 'when creating a new record to scope' do
    before { GroupScopeModel.create(name: 'a-omega', position: 0, group: 'a', kind: 'omega') }

    it 'pushes later positions in scope' do
      expect(a_names).to eq(%w[a-omega a-alpha a-beta a-gamma])
    end

    it 'keeps the sequential order in scope' do
      expect(a_positions).to eq((0..3).to_a)
    end

    it 'dont affect positions in other scopes' do
      expect(b_names).to eq(%w[b-alpha b-beta b-gamma])
      expect(b_positions).to eq((0..2).to_a)
    end
  end

  context 'when updating to a higher position in scope' do
    before { GroupScopeModel.find_by(name: 'a-beta').update(position: 2) }

    it 'shifts objects around' do
      expect(a_names).to eq(%w[a-alpha a-gamma a-beta])
    end

    it 'keeps the sequential order' do
      expect(a_positions).to eq((0..2).to_a)
    end

    it 'dont affect positions in other scopes' do
      expect(b_names).to eq(%w[b-alpha b-beta b-gamma])
      expect(b_positions).to eq((0..2).to_a)
    end
  end

  context 'when updating to a lower position in scope' do
    before { GroupScopeModel.find_by(name: 'a-gamma').update(position: 0) }

    it 'shifts objects around' do
      expect(a_names).to eq(%w[a-gamma a-alpha a-beta])
    end

    it 'keeps the sequential order' do
      expect(a_positions).to eq((0..2).to_a)
    end

    it 'dont affect positions in other scopes' do
      expect(b_names).to eq(%w[b-alpha b-beta b-gamma])
      expect(b_positions).to eq((0..2).to_a)
    end
  end

  context 'when destroying a record in scope' do
    before { GroupScopeModel.find_by(name: 'a-beta').destroy }

    it 'pulls all later positions' do
      expect(a_names).to eq(%w[a-alpha a-gamma])
    end

    it 'keeps the sequential order' do
      expect(a_positions).to eq((0..1).to_a)
    end

    it 'dont affect positions in other scopes' do
      expect(b_names).to eq(%w[b-alpha b-beta b-gamma])
      expect(b_positions).to eq((0..2).to_a)
    end
  end
end
