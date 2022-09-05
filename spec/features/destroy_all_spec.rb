# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'
require 'factories/basic_model'

RSpec.describe 'Function :destroy_all' do
  before do
    create_list(:model_with_many_scopes, 3, :random_position)
    create_list(:model_with_many_scopes, 3, :random_position, kind: 'beta')
  end

  before { ModelWithManyScopes.destroy_all }

  it 'destroy all records' do
    expect(ModelWithManyScopes.all.count).to eq(0)
  end
end
