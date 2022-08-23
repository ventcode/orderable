# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'

RSpec.describe Executor do
  subject { Executor.new(MultiDataBaseModel, :position, :kind)}

  before do
    MultiDataBaseModel.insert_all([
      { name: 'alpha-a', position: 7, kind: 'alpha', group: 'a' },
      { name: 'alpha-b', position: 3, kind: 'alpha', group: 'b' },
      { name: 'alpha-c', position: 6, kind: 'alpha', group: 'c' },
      { name: 'beta-a',  position: 8, kind: 'beta', group: 'a' },
      { name: 'beta-b',  position: 2, kind: 'beta', group: 'b' },
      { name: 'beta-c',  position: 6, kind: 'beta', group: 'c' }
    ])
  end

  let(:alpha_names) { MultiDataBaseModel.where(kind: 'alpha').order(:position).pluck(:name) }
  let(:alpha_positions) { MultiDataBaseModel.where(kind: 'alpha').order(:position).pluck(:position) }

  let(:beta_names) { MultiDataBaseModel.where(kind: 'beta').order(:position).pluck(:name) }
  let(:beta_positions) { MultiDataBaseModel.where(kind: 'beta').order(:position).pluck(:position) }

  context 'with unsupported adapter' do
    before { MultiDataBaseModel.set_db_to_sqlite }
    after { MultiDataBaseModel.set_db_to_postgresql }

    it 'it raise Adapter error' do
      expect { subject.reset }.to raise_error(Orderable::AdapterError)
    end
  end

  context 'with supported adapter' do
    before { subject.reset }

    it 'reset positions for each scope' do
      expect(alpha_names).to eq(%w[alpha-a alpha-b alpha-c])
      expect(beta_names).to eq(%w[beta-a beta-b beta-c])
    end

    it 'keeps the sequential order for each scope' do
      expect(alpha_positions).to eq((0..2).to_a)
      expect(beta_positions).to eq((0..2).to_a)
    end
  end
end
