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

ActiveRecord::Schema[7.0].define(version: 2022_08_20_072353) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.bigint "departure_city_id"
    t.bigint "arrival_city_id"
    t.datetime "departure_time"
    t.datetime "arrival_time"
    t.string "departure_airport"
    t.string "arrival_airport"
    t.float "cost_per_head"
    t.string "flight_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arrival_city_id"], name: "index_flights_on_arrival_city_id"
    t.index ["departure_city_id"], name: "index_flights_on_departure_city_id"
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
  end

  create_table "passenger_groups", force: :cascade do |t|
    t.integer "number_of_passengers"
    t.bigint "itinerary_id", null: false
    t.bigint "origin_city_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "home_city"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bookings", "flights"
  add_foreign_key "bookings", "passenger_groups"
  add_foreign_key "flights", "locations", column: "arrival_city_id"
  add_foreign_key "flights", "locations", column: "departure_city_id"
  add_foreign_key "itineraries", "locations", column: "destination_id"
  add_foreign_key "passenger_groups", "itineraries"
  add_foreign_key "passenger_groups", "locations", column: "origin_city_id"
  add_foreign_key "permissions", "itineraries"
  add_foreign_key "permissions", "users"
end
