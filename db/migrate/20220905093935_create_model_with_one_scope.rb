class CreateModelWithOneScope < ActiveRecord::Migration[6.1]
  def change
    create_table :model_with_one_scopes do |t|
      t.string :name, null: false
      t.string :kind
    end
  end
end
