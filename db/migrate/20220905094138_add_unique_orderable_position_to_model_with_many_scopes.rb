# frozen_string_literal: true

class AddUniqueOrderablePositionToModelWithManyScopes < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      ALTER TABLE "model_with_many_scopes"
        ADD "position" INTEGER,
        ADD UNIQUE("position", "kind", "group") DEFERRABLE INITIALLY DEFERRED
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE "model_with_many_scopes"
        DROP COLUMN "position"
    SQL
  end
end
