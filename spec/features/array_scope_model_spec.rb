# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'

RSpec.describe ArrayScopeModel do
  before do
    ArrayScopeModel.insert_all([
      { name: 'alpha-a-0', position: 0, kind: 'alpha', group: 'a' },
      { name: 'alpha-a-1', position: 1, kind: 'alpha', group: 'a' },
      { name: 'alpha-a-2', position: 2, kind: 'alpha', group: 'a' },
      { name: 'alpha-b-0', position: 0, kind: 'alpha', group: 'b' },
      { name: 'alpha-b-1', position: 1, kind: 'alpha', group: 'b' },
      { name: 'alpha-b-2', position: 2, kind: 'alpha', group: 'b' },
      { name: 'beta-a-0',  position: 0, kind: 'beta', group: 'a' },
      { name: 'beta-a-1',  position: 1, kind: 'beta', group: 'a' },
      { name: 'beta-a-2',  position: 2, kind: 'beta', group: 'a' },
      { name: 'beta-b-0',  position: 0, kind: 'beta', group: 'b' },
      { name: 'beta-b-1',  position: 1, kind: 'beta', group: 'b' },
      { name: 'beta-b-2',  position: 2, kind: 'beta', group: 'b' }
    ])
  end

  let(:alpha_a_names) { ArrayScopeModel.where(kind: 'alpha', group: 'a').order(:position).pluck(:name) }
  let(:alpha_a_positions) { ArrayScopeModel.where(kind: 'alpha', group: 'a').order(:position).pluck(:position) }
  
  let(:alpha_b_names) { ArrayScopeModel.where(kind: 'alpha', group: 'b').order(:position).pluck(:name) }
  let(:alpha_b_positions) { ArrayScopeModel.where(kind: 'alpha', group: 'b').order(:position).pluck(:position) }
  
  let(:beta_a_names) { ArrayScopeModel.where(kind: 'beta', group: 'a').order(:position).pluck(:name) }
  let(:beta_a_positions) { ArrayScopeModel.where(kind: 'beta', group: 'a').order(:position).pluck(:position) }
  
  let(:beta_b_names) { ArrayScopeModel.where(kind: 'beta', group: 'b').order(:position).pluck(:name) }
  let(:beta_b_positions) { ArrayScopeModel.where(kind: 'beta', group: 'b').order(:position).pluck(:position) }
  
  context 'when creating a new record to scope' do
    before { ArrayScopeModel.create(name: 'alpha-a-3', position: 1, kind: 'alpha', group: 'a') }

    it 'pushes later positions in scope' do
      expect(alpha_a_names).to eq(%w[alpha-a-0 alpha-a-3 alpha-a-1 alpha-a-2])
    end

    it 'keeps the sequential order in scope' do
      expect(alpha_a_positions).to eq((0..3).to_a)
    end

    it 'dont affect positions in others scopes' do
      expect(alpha_b_names).to eq(%w[alpha-b-0 alpha-b-1 alpha-b-2])
      expect(alpha_b_positions).to eq((0..2).to_a)
      expect(beta_a_names).to eq(%w[beta-a-0 beta-a-1 beta-a-2])
      expect(beta_a_positions).to eq((0..2).to_a)
      expect(beta_b_names).to eq(%w[beta-b-0 beta-b-1 beta-b-2])
      expect(beta_b_positions).to eq((0..2).to_a)
    end
  end

  context 'when updating to a higher position in scope' do
    before { ArrayScopeModel.find_by(name: 'alpha-b-0').update(position: 1) }

    it 'shifts objects around' do
      expect(alpha_b_names).to eq(%w[alpha-b-1 alpha-b-0 alpha-b-2])
    end

    it 'keeps the sequential order' do
      expect(alpha_b_positions).to eq((0..2).to_a)
    end

    it 'dont affect positions in others scopes' do
      expect(alpha_a_names).to eq(%w[alpha-a-0 alpha-a-1 alpha-a-2])
      expect(alpha_a_positions).to eq((0..2).to_a)
      expect(beta_a_names).to eq(%w[beta-a-0 beta-a-1 beta-a-2])
      expect(beta_a_positions).to eq((0..2).to_a)
      expect(beta_b_names).to eq(%w[beta-b-0 beta-b-1 beta-b-2])
      expect(beta_b_positions).to eq((0..2).to_a)
    end
  end

  context 'when updating to a lower position in scope' do
    before { ArrayScopeModel.find_by(name: 'beta-a-1').update(position: 0) }

    it 'shifts objects around' do
      expect(beta_a_names).to eq(%w[beta-a-1 beta-a-0 beta-a-2])
    end

    it 'keeps the sequential order' do
      expect(beta_a_positions).to eq((0..2).to_a)
    end

    it 'dont affect positions in others scopes' do
      expect(alpha_a_names).to eq(%w[alpha-a-0 alpha-a-1 alpha-a-2])
      expect(alpha_a_positions).to eq((0..2).to_a)
      expect(alpha_b_names).to eq(%w[alpha-b-0 alpha-b-1 alpha-b-2])
      expect(alpha_b_positions).to eq((0..2).to_a)
      expect(beta_b_names).to eq(%w[beta-b-0 beta-b-1 beta-b-2])
      expect(beta_b_positions).to eq((0..2).to_a)
    end
  end

  context 'when destroying a record in scope' do
    before { ArrayScopeModel.find_by(name: 'beta-b-1').destroy }

    it 'pulls all later positions' do
      expect(beta_b_names).to eq(%w[beta-b-0 beta-b-2])
    end

    it 'keeps the sequential order' do
      expect(beta_b_positions).to eq((0..1).to_a)
    end

    it 'dont affect positions in others scopes' do
      expect(alpha_a_names).to eq(%w[alpha-a-0 alpha-a-1 alpha-a-2])
      expect(alpha_a_positions).to eq((0..2).to_a)
      expect(alpha_b_names).to eq(%w[alpha-b-0 alpha-b-1 alpha-b-2])
      expect(alpha_b_positions).to eq((0..2).to_a)
      expect(beta_a_names).to eq(%w[beta-a-0 beta-a-1 beta-a-2])
      expect(beta_a_positions).to eq((0..2).to_a)
    end
  end
end
