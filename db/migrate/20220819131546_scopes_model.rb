# frozen_string_literal: true

class ScopesModel < ActiveRecord::Migration[6.1]
  def change
    create_table :scopes_models do |t|
      t.string :name, null: false
      t.integer :position, null: false
      t.string :kind
      t.string :group
    end
  end
end
