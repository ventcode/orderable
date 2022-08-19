# frozen_string_literal: true

require 'support/database_helper'
require 'support/models'

RSpec.describe SingleElementScope do
  subject { SingleElementScope.create(name: 'alpha-a', position: 0) }

  context 'scope with single element' do
    it 'should be as array' do
      expect(subject.executor.scope.class).to eq(Array)
    end
  end
end
