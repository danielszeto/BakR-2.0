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

ActiveRecord::Schema[8.1].define(version: 2026_11_19_000100) do
  create_table "products", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", null: false
    t.string "category", null: false
    t.text "description", null: false
    t.integer "price_cents", null: false
    t.boolean "available", default: true, null: false
    t.string "product_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available", "category"], name: "index_products_on_available_and_category"
    t.index ["user_id"], name: "index_products_on_user_id"
    t.check_constraint "price_cents BETWEEN 1 AND 99999", name: "valid_product_price"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name"
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "location"
    t.string "contact_email"
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_uid"], name: "index_users_on_google_uid", unique: true
  end

  add_foreign_key "products", "users"
end
