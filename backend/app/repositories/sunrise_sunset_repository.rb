# frozen_string_literal: true

# Data access layer for sunrise/sunset data. Prefers DB, fetches from external API only when missing.
# Mirrors frontend api/sunrise.ts responsibility: single place for "get sunrise data for location + range".
class SunriseSunsetRepository
  class Error < StandardError; end
  class LocationNotFoundError < Error; end
  class ApiError < Error; end
  class InvalidDateRangeError < Error; end

  DATE_FORMAT = "%Y-%m-%d"
  MAX_RANGE_DAYS = 365

  def initialize(
    geocoder: LocationGeocoder.new,
    api_service: SunriseSunsetApiService.new
  )
    @geocoder = geocoder
    @api_service = api_service
  end

  # Returns hash: { location:, start_date:, end_date:, data: [...], source: :database|:api|:"database,api" }
  # Uses DB when possible; calls SunriseSunset.io only for missing days.
  # source: :database = all from DB, :api = all from API, :"database,api" = some from DB + some from API
  def find_or_fetch(location_name:, start_date:, end_date:)
    start_d, end_d = parse_and_validate_dates!(start_date, end_date)
    coords = @geocoder.coordinates_for(location_name)
    raise LocationNotFoundError, "Location not found: #{location_name}" if coords.nil?

    lat, lng = coords
    location_key = SunriseSunsetEntry.location_key_for(lat, lng)

    existing = find_entries(location_key, start_d, end_d)
    existing_dates = existing.map(&:date).to_set
    missing_range = missing_date_ranges(start_d, end_d, existing_dates)
    called_api = false

    if missing_range.any?
      fetched = fetch_and_persist(lat: lat, lng: lng, location_key: location_key, ranges: missing_range)
      existing = (existing + fetched).sort_by(&:date)
      called_api = true
    end

    source = compute_source(existing.size, existing_dates.size, called_api)
    build_response(
      location: location_name.strip,
      start_date: start_d.strftime(DATE_FORMAT),
      end_date: end_d.strftime(DATE_FORMAT),
      entries: existing,
      source: source
    )
  end

  private

  def parse_and_validate_dates!(start_date, end_date)
    raise InvalidDateRangeError, "Missing start_date or end_date" if start_date.blank? || end_date.blank?
    start_d = start_date.is_a?(String) ? Date.parse(start_date) : start_date
    end_d = end_date.is_a?(String) ? Date.parse(end_date) : end_date
    raise InvalidDateRangeError, "start_date must be before or equal to end_date" if start_d > end_d
    raise InvalidDateRangeError, "Date range cannot exceed #{MAX_RANGE_DAYS} days" if (end_d - start_d).to_i >= MAX_RANGE_DAYS
    [start_d, end_d]
  rescue ArgumentError => e
    raise InvalidDateRangeError, "Invalid date format. Use YYYY-MM-DD: #{e.message}"
  end

  def find_entries(location_key, start_d, end_d)
    SunriseSunsetEntry
      .where(location_key: location_key)
      .where(date: start_d..end_d)
      .order(:date)
      .to_a
  end

  def missing_date_ranges(start_d, end_d, existing_dates)
    missing = (start_d..end_d).reject { |d| existing_dates.include?(d) }
    return [] if missing.empty?
    # Group consecutive dates into ranges for minimal API calls
    ranges = []
    missing.sort.each do |d|
      if ranges.empty? || ranges.last.last != d - 1
        ranges << [d, d]
      else
        ranges.last[1] = d
      end
    end
    ranges.map { |a, b| (a..b) }
  end

  def fetch_and_persist(lat:, lng:, location_key:, ranges:)
    all = []
    ranges.each do |range|
      start_d = range.first
      end_d = range.last
      raw = @api_service.fetch_range(lat: lat, lng: lng, date_start: start_d, date_end: end_d)
      entries = raw.map do |h|
        SunriseSunsetEntry.find_or_initialize_by(location_key: location_key, date: h[:date]).tap do |e|
          e.assign_attributes(
            lat: lat,
            lng: lng,
            sunrise: h[:sunrise],
            sunset: h[:sunset],
            golden_hour: h[:golden_hour],
            timezone: h[:timezone]
          )
          e.save!
          all << e
        end
      end
    end
    all
  end

  def compute_source(total, from_db_count, called_api)
    return :database if total.positive? && !called_api
    return :api if called_api && from_db_count.zero?
    :"database,api"
  end

  def build_response(location:, start_date:, end_date:, entries:, source: :database)
    {
      location: location,
      start_date: start_date,
      end_date: end_date,
      source: source.to_s,
      data: entries.map do |e|
        {
          date: e.date.strftime(DATE_FORMAT),
          sunrise: e.sunrise || "",
          sunset: e.sunset || "",
          golden_hour: e.golden_hour || ""
        }
      end
    }
  end
end
