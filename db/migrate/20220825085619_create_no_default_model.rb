# frozen_string_literal: true

class CreateNoDefaultModel < ActiveRecord::Migration[6.1]
  def change
    create_table :no_default_models do |t|
      t.string :name, null: false
      t.integer :position, null: false
    end
  end
end
