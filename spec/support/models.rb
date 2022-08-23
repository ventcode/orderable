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
  def executor
    executor ||= Orderable::Executor.new(self, :position, scope: 'somecope')
  end
end
