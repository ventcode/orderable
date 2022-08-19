class Addons < ActiveRecord::Migration[6.1]
  def change
    create_table :addons do |t|
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.references :basic_model, foreign_key: true, index: false
    end
  end
end
