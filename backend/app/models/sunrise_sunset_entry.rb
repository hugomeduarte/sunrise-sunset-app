# frozen_string_literal: true

class SunriseSunsetEntry < ApplicationRecord
  validates :location_key, :date, :lat, :lng, presence: true
  validates :date, uniqueness: { scope: :location_key }

  def self.location_key_for(lat, lng)
    "#{lat.to_f.round(4)},#{lng.to_f.round(4)}"
  end
end
