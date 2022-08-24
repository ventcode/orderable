# frozen_string_literal: true

class BasicModel < ActiveRecord::Base
  has_many :addons

  orderable :position
end

class ScopesModel < ActiveRecord::Base
end

class ArrayScopeModel < ScopesModel
  orderable :position, scope: %i[kind group]
end

class GroupScopeModel < ScopesModel
  orderable :position, scope: :group
end

class NoValidationModel < ActiveRecord::Base
  self.table_name = 'basic_models'

  orderable :position, validate: false
end
