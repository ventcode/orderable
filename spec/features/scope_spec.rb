# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'

RSpec.shared_examples 'does not affect for single scope' do |_actions|
  let(:actions) { instance_exec(&action) }

  it 'does not affect records outside of scope' do
    expect { single_scope_action }.not_to change(out_of_single_scope.reload, :position)
  end
end

RSpec.shared_examples 'does not affect for many scopes' do |_actions|
  let(:actions) { instance_exec(&action) }

  it 'does not affect records outside of scope' do
    expect { many_scope_action }.not_to change(out_of_many_scopes.reload, :position)
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
  let!(:out_of_many_scopes) { ModelWithManyScopes.create!(name: 'other', position: 0, kind: 'alpha', group: 'a') }

  context 'when creating a new record' do
    let(:single_scope_action) { ModelWithOneScope.create(name: 'd', position: 0, kind: 'alpha') }
    let(:many_scope_action) { ModelWithManyScopes.create(name: 'd', position: 0, kind: 'alpha', group: 'a') }

    it_should_behave_like 'does not affect for single scope', actions: -> { single_scope_action out_of_single_scope }
    it_should_behave_like 'does not affect for many scopes', actions: -> { many_scope_action out_of_many_scopes }
  end

  context 'when updating a record' do
    let(:single_scope_action) { ModelWithOneScope.where(group: nil).last.update(position: 0) }
    let(:many_scope_action) { ModelWithManyScopes.where.not(group: nil).last.update(position: 0) }

    it_should_behave_like 'does not affect for single scope', actions: -> { single_scope_action out_of_single_scope }
    it_should_behave_like 'does not affect for many scopes', actions: -> { many_scope_action out_of_many_scopes }
  end

  context 'when destroying a record' do
    let(:single_scope_action) { ModelWithOneScope.where(group: nil).last.destroy }
    let(:many_scope_action) { ModelWithManyScopes.where.not(group: nil).last.destroy }

    it_should_behave_like 'does not affect for single scope', actions: -> { single_scope_action out_of_single_scope }
    it_should_behave_like 'does not affect for many scopes', actions: -> { many_scope_action out_of_many_scopes }
  end
end
