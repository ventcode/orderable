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

class Executor < Orderable::Executor
end

class MultiDataBaseModel < ScopesModel
  orderable :position, scope: :group

  def self.set_db_to_sqlite
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: 'db/development.sqlite3'
    )
  end

  def self.set_db_to_postgresql
    ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      database: 'orderable_development'
    )
  end
end
