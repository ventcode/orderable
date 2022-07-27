# frozen_string_literal: true

class CreateBasicModel < ActiveRecord::Migration[6.1]
  def change
    create_table :basic_models do |t|
      t.string :name, null: false
      t.integer :position, null: false, default: 0
    end
  end
end
