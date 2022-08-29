# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'

RSpec.shared_examples 'does not affect outside of scope' do
  it 'does not affect records outside of scope' do
    expect { action }.not_to change { out_of_scope.reload.position }
  end
end

RSpec.describe 'asdasdasd' do
  before do
    ModelWithOneScope.insert_all([
      { name: 'a', position: 0, kind: 'alpha' },
      { name: 'b', position: 1, kind: 'alpha' },
      { name: 'c', position: 2, kind: 'alpha' }
    ])

    ModelWithManyScopes.insert_all([
      { name: 'a', position: 0, kind: 'beta', group: 'a' },
      { name: 'b', position: 1, kind: 'beta', group: 'a' },
      { name: 'c', position: 2, kind: 'beta', group: 'a' }
    ])
  end

  let!(:out_of_single_scope) { ModelWithOneScope.create!(name: 'other', position: 0, kind: 'beta') }
  let!(:out_of_many_scopes) { ModelWithManyScopes.create!(name: 'other', position: 0, kind: 'beta', group: 'b') }

  context 'when creating a new record' do
    let(:single_scope_action) { ModelWithOneScope.create(name: 'd', position: 0, kind: 'alpha') }
    let(:many_scope_action) { ModelWithManyScopes.create(name: 'd', position: 0, kind: 'beta', group: 'a') }

    context 'for single scope' do
      it_should_behave_like 'does not affect outside of scope' do
        let(:action) { single_scope_action }
        let(:out_of_scope) { out_of_single_scope }
      end
    end

    context 'for many scope' do
      it_should_behave_like 'does not affect outside of scope' do
        let(:action) { many_scope_action }
        let(:out_of_scope) { out_of_many_scopes }
      end
    end
  end

  context 'when updating a record' do
    let(:single_scope_action) { ModelWithOneScope.where(group: nil).last.update(position: 0) }
    let(:many_scope_action) { ModelWithManyScopes.where.not(group: nil).last.update(position: 0) }

    context 'for single scope' do
      it_should_behave_like 'does not affect outside of scope' do
        let(:action) { single_scope_action }
        let(:out_of_scope) { out_of_single_scope }
      end
    end

    context 'for many scope' do
      it_should_behave_like 'does not affect outside of scope' do
        let(:action) { many_scope_action }
        let(:out_of_scope) { out_of_many_scopes }
      end
    end
  end

  context 'when destroying a record' do
    let(:single_scope_action) { ModelWithOneScope.where(group: nil, kind: 'alpha').last.destroy }
    let(:many_scope_action) { ModelWithManyScopes.where(kind: 'beta', group: 'a').last.destroy }

    context 'for single scope' do
      it_should_behave_like 'does not affect outside of scope' do
        let(:action) { single_scope_action }
        let(:out_of_scope) { out_of_single_scope }
      end
    end

    context 'for many scope' do
      it_should_behave_like 'does not affect outside of scope' do
        let(:action) { many_scope_action }
        let(:out_of_scope) { out_of_many_scopes }
      end
    end
  end
end
