# frozen_string_literal: true

class CreateSunriseSunsetEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :sunrise_sunset_entries do |t|
      t.string :location_key, null: false, index: true
      t.date :date, null: false, index: true
      t.decimal :lat, precision: 10, scale: 6, null: false
      t.decimal :lng, precision: 10, scale: 6, null: false
      t.string :sunrise
      t.string :sunset
      t.string :golden_hour
      t.string :timezone

      t.timestamps
    end

    add_index :sunrise_sunset_entries, %i[location_key date], unique: true
    add_index :sunrise_sunset_entries, %i[lat lng date], unique: true
  end
end
