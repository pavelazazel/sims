# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_02_15_160900) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "brands", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "consumable_movements", force: :cascade do |t|
    t.bigint "consumable_id", null: false
    t.bigint "location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consumable_id"], name: "index_consumable_movements_on_consumable_id"
    t.index ["location_id"], name: "index_consumable_movements_on_location_id"
  end

  create_table "consumable_types", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "consumables", force: :cascade do |t|
    t.string "title", null: false
    t.integer "quantity_in_stock", default: 0, null: false
    t.integer "quantity_in_use", default: 0, null: false
    t.integer "quantity_ready_to_refill", default: 0, null: false
    t.integer "quantity_at_refill", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "consumable_type_id", null: false
    t.string "placement"
    t.index ["consumable_type_id"], name: "index_consumables_on_consumable_type_id"
  end

  create_table "consumables_names", id: false, force: :cascade do |t|
    t.integer "consumable_id"
    t.integer "name_id"
  end

  create_table "devices", force: :cascade do |t|
    t.bigint "name_id", null: false
    t.string "inventory_number", null: false
    t.string "serial_number", null: false
    t.bigint "location_id", null: false
    t.text "comment", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_devices_on_location_id"
    t.index ["name_id"], name: "index_devices_on_name_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "department", null: false
    t.string "room", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "names", force: :cascade do |t|
    t.bigint "type_id", null: false
    t.bigint "brand_id", null: false
    t.string "model", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_names_on_brand_id"
    t.index ["type_id"], name: "index_names_on_type_id"
  end

  create_table "types", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "consumable_movements", "consumables"
  add_foreign_key "consumable_movements", "locations"
  add_foreign_key "devices", "locations"
  add_foreign_key "devices", "names"
  add_foreign_key "names", "brands"
  add_foreign_key "names", "types"
end
