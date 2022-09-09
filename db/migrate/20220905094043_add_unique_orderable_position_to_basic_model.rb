# frozen_string_literal: true

class AddUniqueOrderablePositionToBasicModel < ActiveRecord::Migration[6.1]
  def up
    add_column :basic_models, :position, :integer

    execute <<-SQL
      ALTER TABLE "basic_models"
        ADD UNIQUE("position") DEFERRABLE INITIALLY DEFERRED
    SQL
  end
  def down
    remove_column :basic_models, :position
  end
end
