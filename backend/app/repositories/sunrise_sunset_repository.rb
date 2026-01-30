# frozen_string_literal: true

# Data access layer for sunrise/sunset data. Prefers DB, fetches from external API only when missing.
# Mirrors frontend api/sunrise.ts responsibility: single place for "get sunrise data for location + range".
#
# Ruby vs TypeScript: in Ruby we usually have one class per file. "Types" = hash shape (no separate types file).
# "Utils" = private methods below, or separate services (e.g. LocationGeocoder). Constants = in the class, like below.
class SunriseSunsetRepository
  include Pagination

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

  # Returns hash: { location:, start_date:, end_date:, data: [...], pagination: { page:, total_pages:, ... }, source: }
  # Uses DB when possible; calls SunriseSunset.io only for missing days.
  #
  # Pagination: we slice the full date range by (page, limit). Page 1 + limit 31 = first 31 days, etc.
  def find_or_fetch(location_name:, start_date:, end_date:, limit: Pagination::DEFAULT_LIMIT, page: 1)
    start_d, end_d = parse_and_validate_dates!(start_date, end_date)
    limit = normalize_limit(limit)
    page = normalize_page(page)

    coords = @geocoder.coordinates_for(location_name)
    raise LocationNotFoundError, "Location not found: #{location_name}" if coords.nil?

    all_dates = (start_d..end_d).to_a
    total = all_dates.size
    page_dates = slice_for_page(all_dates, page, limit)

    if page_dates.empty?
      return build_response(location: location_name.strip, start_date: start_d, end_date: end_d, entries: [], page: page, limit: limit, total: total, source: :database)
    end

    lat, lng = coords
    location_key = SunriseSunsetEntry.location_key_for(lat, lng)
    range_start = page_dates.first
    range_end = page_dates.last

    existing = find_entries(location_key, range_start, range_end)
    existing_dates = existing.map(&:date).to_set
    missing = missing_date_ranges(range_start, range_end, existing_dates)
    called_api = false

    if missing.any?
      fetched = fetch_and_persist(lat: lat, lng: lng, location_key: location_key, ranges: missing)
      existing = (existing + fetched).sort_by(&:date)
      called_api = true
    end

    source = compute_source(existing.size, existing_dates.size, called_api)
    build_response(
      location: location_name.strip,
      start_date: start_d,
      end_date: end_d,
      entries: existing,
      page: page,
      limit: limit,
      total: total,
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

  def build_response(location:, start_date:, end_date:, entries:, page:, limit: Pagination::DEFAULT_LIMIT, total:, source: :database)
    {
      location: location,
      start_date: start_date.is_a?(Date) ? start_date.strftime(DATE_FORMAT) : start_date,
      end_date: end_date.is_a?(Date) ? end_date.strftime(DATE_FORMAT) : end_date,
      source: source.to_s,
      pagination: build_pagination_meta(page, limit, total),
      data: entries.map { |e| entry_to_hash(e) }
    }
  end

  def entry_to_hash(e)
    {
      date: e.date.strftime(DATE_FORMAT),
      sunrise: e.sunrise || "",
      sunset: e.sunset || "",
      golden_hour: e.golden_hour || ""
    }
  end
end
