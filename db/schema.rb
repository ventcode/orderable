# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_220_905_094_233) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'basic_models', force: :cascade do |t|
    t.string 'name', null: false
    t.integer 'position'
    t.index ['position'], name: 'basic_models_position_key', unique: true
  end

  create_table 'model_with_many_scopes', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'kind'
    t.string 'group'
    t.integer 'position'
    t.index %w[position kind group], name: 'model_with_many_scopes_position_kind_group_key', unique: true
  end

  create_table 'model_with_one_scopes', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'kind'
    t.integer 'position'
    t.index %w[position kind], name: 'model_with_one_scopes_position_kind_key', unique: true
  end
end
