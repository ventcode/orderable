# frozen_string_literal: true

class BasicModel < ActiveRecord::Base
  orderable :position
end

class ScopesModel < ActiveRecord::Base
end

class ArrayScopeModel < ScopesModel
  orderable :position, scope: [:kind, :group]
end

class GroupScopeModel < ScopesModel
  orderable :position, scope: :group
end
