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

ActiveRecord::Schema[8.0].define(version: 2025_11_17_193245) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "assessments", force: :cascade do |t|
    t.bigint "enrollment_id", null: false
    t.bigint "assignment_id", null: false
    t.float "score"
    t.datetime "submitted_at"
    t.datetime "assessed_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_assessments_on_assignment_id"
    t.index ["enrollment_id"], name: "index_assessments_on_enrollment_id"
  end

  create_table "assignments", force: :cascade do |t|
    t.string "title"
    t.integer "assignment_type"
    t.integer "max_score"
    t.datetime "deadline"
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "assessments_count", default: 0, null: false
    t.integer "submissions_count", default: 0, null: false
    t.integer "assessed_count", default: 0, null: false
    t.index ["course_id"], name: "index_assignments_on_course_id"
    t.index ["title", "course_id"], name: "index_unique_assignment_per_course", unique: true
  end

  create_table "courses", force: :cascade do |t|
    t.string "name"
    t.string "course_code"
    t.integer "semester"
    t.integer "month"
    t.integer "year"
    t.boolean "is_completed", default: false, null: false
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "enrollments_count", default: 0, null: false
    t.integer "assignments_count", default: 0, null: false
    t.index ["name", "course_code", "semester", "year", "month", "organization_id"], name: "index_unique_course_details", unique: true
    t.index ["organization_id"], name: "index_courses_on_organization_id"
    t.index ["user_id"], name: "index_courses_on_user_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.integer "status"
    t.string "grade"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "total_score", precision: 10, scale: 2, default: "0.0", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["user_id", "course_id"], name: "index_enrollments_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization_code"
    t.jsonb "settings"
    t.index ["organization_code"], name: "index_organizations_on_organization_code", unique: true
  end

  create_table "resources", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "visible", default: false
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_resources_on_course_id"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.string "org_member_id"
    t.text "bio", default: ""
    t.string "phone_number", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_profiles_on_user_id", unique: true
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
    t.datetime "reset_password_token_used_at"
    t.integer "activated_by_id"
    t.index ["active"], name: "index_users_on_active"
    t.index ["deactivated_by_id"], name: "index_users_on_deactivated_by_id"
    t.index ["email", "organization_id"], name: "index_users_on_email_and_org_id", unique: true, where: "(organization_id IS NOT NULL)"
    t.index ["email"], name: "index_users_on_email_global_admin", unique: true, where: "(organization_id IS NULL)"
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assessments", "assignments"
  add_foreign_key "assessments", "enrollments"
  add_foreign_key "assignments", "courses"
  add_foreign_key "courses", "organizations"
  add_foreign_key "courses", "users"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "users"
  add_foreign_key "resources", "courses"
  add_foreign_key "user_profiles", "users"
  add_foreign_key "users", "organizations"
  add_foreign_key "users", "users", column: "deactivated_by_id"
end
