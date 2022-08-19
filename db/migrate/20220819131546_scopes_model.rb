class ScopesModel < ActiveRecord::Migration[6.1]
  def change
    create_table :scopes_models do |t|
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.string :kind, null: false, default: 'alpha'
      t.string :group, null: false, default: 'a'
    end
  end
end
