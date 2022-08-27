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

ActiveRecord::Schema[7.0].define(version: 2022_08_26_193256) do
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

  create_table "airports", force: :cascade do |t|
    t.string "name"
    t.bigint "location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
    t.index ["location_id"], name: "index_airports_on_location_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "passenger_group_id", null: false
    t.bigint "flight_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_id"], name: "index_bookings_on_flight_id"
    t.index ["passenger_group_id"], name: "index_bookings_on_passenger_group_id"
  end

  create_table "flights", force: :cascade do |t|
    t.datetime "departure_time"
    t.datetime "arrival_time"
    t.bigint "departure_airport_id"
    t.bigint "arrival_airport_id"
    t.float "cost_per_head"
    t.string "flight_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arrival_airport_id"], name: "index_flights_on_arrival_airport_id"
    t.index ["departure_airport_id"], name: "index_flights_on_departure_airport_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "url"
    t.bigint "location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_images_on_location_id"
  end

  create_table "itineraries", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.float "budget"
    t.bigint "destination_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_id"], name: "index_itineraries_on_destination_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "city"
    t.string "country"
    t.string "region"
    t.float "longitude"
    t.float "latitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "city_code"
    t.string "country_code"
  end

  create_table "passenger_groups", force: :cascade do |t|
    t.bigint "itinerary_id", null: false
    t.bigint "origin_city_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "adults"
    t.integer "children"
    t.index ["itinerary_id"], name: "index_passenger_groups_on_itinerary_id"
    t.index ["origin_city_id"], name: "index_passenger_groups_on_origin_city_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "itinerary_id", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["itinerary_id"], name: "index_permissions_on_itinerary_id"
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "search_results", force: :cascade do |t|
    t.bigint "search_id", null: false
    t.bigint "flight_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_id"], name: "index_search_results_on_flight_id"
    t.index ["search_id"], name: "index_search_results_on_search_id"
  end

  create_table "searches", force: :cascade do |t|
    t.string "origin"
    t.string "destination"
    t.string "date"
    t.string "adults"
    t.string "children"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.bigint "home_city_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["home_city_id"], name: "index_users_on_home_city_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "airports", "locations"
  add_foreign_key "bookings", "flights"
  add_foreign_key "bookings", "passenger_groups"
  add_foreign_key "flights", "airports", column: "arrival_airport_id"
  add_foreign_key "flights", "airports", column: "departure_airport_id"
  add_foreign_key "images", "locations"
  add_foreign_key "itineraries", "locations", column: "destination_id"
  add_foreign_key "passenger_groups", "itineraries"
  add_foreign_key "passenger_groups", "locations", column: "origin_city_id"
  add_foreign_key "permissions", "itineraries"
  add_foreign_key "permissions", "users"
  add_foreign_key "search_results", "flights"
  add_foreign_key "search_results", "searches"
  add_foreign_key "users", "locations", column: "home_city_id"
end
