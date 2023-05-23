# frozen_string_literal: true

class AddUniqueOrderablePositionToModelWithManyScopes < ActiveRecord::Migration[6.1]
  def up
    add_column :model_with_many_scopes, :position, :integer

    execute(<<-SQL)
      ALTER TABLE model_with_many_scopes
      ADD UNIQUE(position, kind, "group") DEFERRABLE INITIALLY DEFERRED;
    SQL
  end

  def down
    remove_column :model_with_many_scopes, :position
  end
end
