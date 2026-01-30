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

ActiveRecord::Schema[8.1].define(version: 2025_08_12_000001) do
  create_table "sunrise_sunset_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.string "golden_hour"
    t.decimal "lat", precision: 10, scale: 6, null: false
    t.decimal "lng", precision: 10, scale: 6, null: false
    t.string "location_key", null: false
    t.string "sunrise"
    t.string "sunset"
    t.string "timezone"
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_sunrise_sunset_entries_on_date"
    t.index ["lat", "lng", "date"], name: "index_sunrise_sunset_entries_on_lat_and_lng_and_date", unique: true
    t.index ["location_key", "date"], name: "index_sunrise_sunset_entries_on_location_key_and_date", unique: true
    t.index ["location_key"], name: "index_sunrise_sunset_entries_on_location_key"
  end
end
