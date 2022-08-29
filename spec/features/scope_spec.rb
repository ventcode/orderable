# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'

# shared_examples 'does not affect' do |action, out_of_scope|
#   it 'does not affect records outside of scope' do
#     expect { action }.not_to change { out_of_scope.reload.position }
#   end
# end

RSpec.describe 'asdasdasd' do
  before do
    ModelWithOneScope.insert_all([
      { name: 'a', position: 0, kind: 'alpha' },
      { name: 'b', position: 1, kind: 'alpha' },
      { name: 'c', position: 2, kind: 'alpha' }
    ])
  end

  let!(:out_of_scope) { ModelWithOneScope.create!(name: 'other', position: 0, kind: 'beta') }

  context 'when creating a new record' do
    let(:action) { ModelWithOneScope.create(name: 'd', position: 0, kind: 'alpha') }

    it 'does not affect records outside of scope' do
      expect { action }.not_to change { out_of_scope.reload.position }
    end
  end

  context 'when updating a record' do
    let(:action) { ModelWithOneScope.last.update(position: 1) }

    it 'does not affect records outside of scope' do
      expect { action }.not_to change { out_of_scope.reload.position }
    end
  end

  context 'when destroying a record' do
    let(:action) { ModelWithOneScope.find_by(name: 'c').destroy }

    it 'does not affect records outside of scope' do
      expect { action }.not_to change { out_of_scope.reload.position }
    end
  end
end
