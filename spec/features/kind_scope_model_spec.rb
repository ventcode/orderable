# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'

RSpec.describe KindScopeModel do
  before do
    KindScopeModel.insert_all([
      { name: 'alpha-a', position: 0, kind: 'alpha', group: 'a' },
      { name: 'alpha-b', position: 1, kind: 'alpha', group: 'b' },
      { name: 'alpha-c', position: 2, kind: 'alpha', group: 'c' },
      { name: 'beta-a',  position: 0, kind: 'beta', group: 'a' },
      { name: 'beta-b',  position: 1, kind: 'beta', group: 'b' },
      { name: 'beta-c',  position: 2, kind: 'beta', group: 'c' }
    ])
  end

  let(:alpha_names) { KindScopeModel.where(kind: 'alpha').order(:position).pluck(:name) }
  let(:alpha_positions) { KindScopeModel.where(kind: 'alpha').order(:position).pluck(:position) }

  let(:beta_names) { KindScopeModel.where(kind: 'beta').order(:position).pluck(:name) }
  let(:beta_positions) { KindScopeModel.where(kind: 'beta').order(:position).pluck(:position) }

  context 'when creating a new record to scope' do
    before { KindScopeModel.create(name: 'beta-e', position: 1, kind: 'beta', group: 'e') }

    it 'pushes later positions in scope' do
      expect(beta_names).to eq(%w[beta-a beta-e beta-b beta-c])
    end

    it 'keeps the sequential order in scope' do
      expect(beta_positions).to eq((0..3).to_a)
    end

    it 'dont affect positions in other scopes' do
      expect(alpha_names).to eq(%w[alpha-a alpha-b alpha-c])
      expect(alpha_positions).to eq((0..2).to_a)
    end
  end

  context 'when updating to a higher position in scope' do
    before { KindScopeModel.find_by(name: 'beta-a').update(position: 2) }

    it 'shifts objects around' do
      expect(beta_names).to eq(%w[beta-b beta-c beta-a])
    end

    it 'keeps the sequential order' do
      expect(beta_positions).to eq((0..2).to_a)
    end

    it 'dont affect positions in other scopes' do
      expect(alpha_names).to eq(%w[alpha-a alpha-b alpha-c])
      expect(alpha_positions).to eq((0..2).to_a)
    end
  end

  context 'when updating to a lower position in scope' do
    before { KindScopeModel.find_by(name: 'beta-c').update(position: 0) }

    it 'shifts objects around' do
      expect(beta_names).to eq(%w[beta-c beta-a beta-b])
    end

    it 'keeps the sequential order' do
      expect(beta_positions).to eq((0..2).to_a)
    end

    it 'dont affect positions in other scopes' do
      expect(alpha_names).to eq(%w[alpha-a alpha-b alpha-c])
      expect(alpha_positions).to eq((0..2).to_a)
    end
  end

  context 'when destroying a record in scope' do
    before { KindScopeModel.find_by(name: 'beta-b').destroy }

    it 'pulls all later positions' do
      expect(beta_names).to eq(%w[beta-a beta-c])
    end

    it 'keeps the sequential order' do
      expect(beta_positions).to eq((0..1).to_a)
    end

    it 'dont affect positions in other scopes' do
      expect(alpha_names).to eq(%w[alpha-a alpha-b alpha-c])
      expect(alpha_positions).to eq((0..2).to_a)
    end
  end
end
