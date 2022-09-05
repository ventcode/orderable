# frozen_string_literal: true

class AddUniqueOrderablePositionToModelWithOneScope < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      ALTER TABLE "model_with_one_scopes"
        ADD "position" INTEGER,
        ADD UNIQUE("position", "kind") DEFERRABLE INITIALLY DEFERRED
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE "model_with_one_scopes"
        DROP COLUMN "position"
    SQL
  end
end
