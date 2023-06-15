# frozen_string_literal: true

class CreateModelWithManyScopes < ActiveRecord::Migration[5.0]
  def change
    create_table :model_with_many_scopes do |t|
      t.string :name, null: false
      t.string :kind
      t.string :group
    end
  end
end
