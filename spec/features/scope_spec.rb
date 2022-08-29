# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'

RSpec.shared_examples 'does not affect outside of scope' do
  it 'does not affect records outside of scope' do
    expect { action }.not_to change { out_of_scope.reload.position }
  end
end

RSpec.describe 'Configuration option :scope' do
  before do
    ModelWithOneScope.insert_all([
      { name: 'a', position: 0, kind: 'alpha', group: 'a' },
      { name: 'b', position: 1, kind: 'alpha', group: 'a' },
      { name: 'c', position: 2, kind: 'alpha', group: 'a' }
    ])
  end

  let!(:out_of_scope) { ModelWithOneScope.create!(name: 'other', position: 0, kind: 'beta', group: 'b') }

  [ModelWithManyScopes, ModelWithOneScope].each do |model|
    describe model do
      context 'when creating a new record' do
        let(:action) { model.create(name: 'd', position: 0, kind: 'alpha', group: 'a') }

        include_examples 'does not affect outside of scope'
      end

      context 'when updating a record' do
        let(:action) { model.where(kind: 'alpha', group: 'a').last.update(position: 0) }

        include_examples 'does not affect outside of scope'
      end

      context 'when destroying a record' do
        let(:action) { model.where(kind: 'alpha', group: 'a').last.destroy }

        include_examples 'does not affect outside of scope'
      end
    end
  end
end
