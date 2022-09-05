class AddUniqueOrderablePositionToBasicModel < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      ALTER TABLE "basic_models"
        ADD "position" INTEGER,
        ADD UNIQUE("position") DEFERRABLE INITIALLY DEFERRED
    SQL
  end
  def down
    execute <<-SQL
      ALTER TABLE "basic_models"
        DROP COLUMN "position"
    SQL
  end
end
