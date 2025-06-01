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

ActiveRecord::Schema[8.0].define(version: 2025_06_01_013318) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization_code"
    t.jsonb "settings"
    t.index ["organization_code"], name: "index_organizations_on_organization_code", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.integer "role"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.bigint "deactivated_by_id"
    t.datetime "deactivated_at", precision: nil
    t.string "security_question"
    t.string "security_answer_digest"
    t.jsonb "settings"
    t.index ["active"], name: "index_users_on_active"
    t.index ["deactivated_by_id"], name: "index_users_on_deactivated_by_id"
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

  add_foreign_key "users", "organizations"
  add_foreign_key "users", "users", column: "deactivated_by_id"
end
