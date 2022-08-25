# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'
require 'factories/scopes_model'

RSpec.describe Executor do
  subject { Executor.new(MultiDataBaseModel, :position, :group) }

  before do
    3.times { |i| FactoryBot.create(:ScopesModel, :random_position, name: "group-a-#{i}", group: 'a') }
    3.times { |i| FactoryBot.create(:ScopesModel, :random_position, name: "group-b-#{i}", group: 'b') }
  end

  let(:alpha_names) { ScopesModel.where(group: 'a').order(:position).pluck(:name) }
  let(:alpha_positions) { ScopesModel.where(group: 'a').order(:position).pluck(:position) }

  let(:beta_names) { ScopesModel.where(group: 'b').order(:position).pluck(:name) }
  let(:beta_positions) { ScopesModel.where(group: 'b').order(:position).pluck(:position) }

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
      expect(alpha_names).to eq(%w[group-a-0 group-a-1 group-a-2])
      expect(beta_names).to eq(%w[group-b-0 group-b-1 group-b-2])
    end

    it 'keeps the sequential order for each scope' do
      expect(alpha_positions).to eq((0..2).to_a)
      expect(beta_positions).to eq((0..2).to_a)
    end
  end
end
