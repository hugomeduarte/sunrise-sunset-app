# frozen_string_literal: true

require "net/http"

# Calls SunriseSunset.io API with lat/lng and date range. Returns array of hashes; handles API errors and null sun times.
class SunriseSunsetApiService
  BASE_URL = "https://api.sunrisesunset.io/json"

  class ApiFailureError < StandardError; end

  def fetch_range(lat:, lng:, date_start:, date_end:)
    start_str = date_start.is_a?(Date) ? date_start.strftime("%Y-%m-%d") : date_start
    end_str = date_end.is_a?(Date) ? date_end.strftime("%Y-%m-%d") : date_end

    uri = URI(BASE_URL)
    uri.query = URI.encode_www_form(
      lat: lat,
      lng: lng,
      date_start: start_str,
      date_end: end_str,
      time_format: "24"
    )

    res = Net::HTTP.get_response(uri)
    raise ApiFailureError, "SunriseSunset.io returned #{res.code}" unless res.is_a?(Net::HTTPSuccess)

    body = begin
      JSON.parse(res.body)
    rescue JSON::ParserError => e
      raise ApiFailureError, "Invalid API response: #{e.message}"
    end

    status = body["status"]
    raise ApiFailureError, "API error: #{status}" if status && status != "OK"

    results = body["results"]
    items = results.is_a?(Array) ? results : [results].compact
    items.filter_map { |r| parse_result(r) }
  end

  private

  def parse_result(r)
    return nil unless r
    date_str = r["date"]
    return nil unless date_str
    date = Date.parse(date_str)
    {
      date: date,
      sunrise: r["sunrise"].to_s.presence,
      sunset: r["sunset"].to_s.presence,
      golden_hour: r["golden_hour"].to_s.presence,
      timezone: r["timezone"].to_s.presence
    }
  rescue ArgumentError
    nil
  end
end
