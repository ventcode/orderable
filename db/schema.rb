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

ActiveRecord::Schema.define(version: 2022_08_19_081013) do

  create_table "addons", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.integer "basic_model_id"
  end

  create_table "basic_models", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", default: 0, null: false
  end

  add_foreign_key "addons", "basic_models"
end
