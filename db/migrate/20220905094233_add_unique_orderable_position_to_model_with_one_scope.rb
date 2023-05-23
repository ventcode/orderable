# frozen_string_literal: true

class AddUniqueOrderablePositionToModelWithOneScope < ActiveRecord::Migration[6.1]
  def up
    add_column :model_with_one_scopes, :position, :integer

    execute(<<-SQL)
      ALTER TABLE model_with_one_scopes
      ADD UNIQUE(position, kind) DEFERRABLE INITIALLY DEFERRED;
    SQL
  end

  def down
    remove_column :model_with_one_scopes, :position
  end
end
