# frozen_string_literal: true

class CreateBasicModel < ActiveRecord::Migration[5.0]
  def change
    create_table :basic_models do |t|
      t.string :name, null: false
    end
  end
end
