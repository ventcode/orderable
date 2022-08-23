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
  attr_accessor :executor
  include Orderable

end

class Executor < Orderable::Executor
end

class MultiDataBaseModel < ScopesModel
  orderable :position, scope: :kind

  def self.set_db_to_sqlite
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: 'db/development.sqlite3',
  )
  end

  def self.set_db_to_postgresql
    ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      database: 'orderable_development'
  )
  end
end
