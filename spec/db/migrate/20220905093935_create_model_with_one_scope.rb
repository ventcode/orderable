# frozen_string_literal: true

class CreateModelWithOneScope < ActiveRecord::Migration[5.0]
  def change
    create_table :model_with_one_scopes do |t|
      t.string :name, null: false
      t.string :kind
    end
  end
end
