# frozen_string_literal: true

class BasicModel < ActiveRecord::Base
  orderable :position
end

class ScopesModel < ActiveRecord::Base
end

class KindScopeModel < ScopesModel 
  orderable :position, scope: :kind
end

class GroupScopeModel < ScopesModel 
  orderable :position, scope: :group
end

class SingleElementScope < BasicModel
  attr_reader :executor
  include Orderable

  before_create do
    @executor = Executor.new(self, :position, 'scope')
  end
end
