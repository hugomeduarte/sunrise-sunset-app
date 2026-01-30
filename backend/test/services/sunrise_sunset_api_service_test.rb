# frozen_string_literal: true

require "test_helper"

class SunriseSunsetApiServiceTest < ActiveSupport::TestCase
  setup do
    @service = SunriseSunsetApiService.new
  end

  test "fetch_range returns array of hashes with date, sunrise, sunset, golden_hour" do
    stub_request(:get, "https://api.sunrisesunset.io/json")
      .with(query: hash_including("lat" => "38.7223", "lng" => "-9.1393", "date_start" => "2025-08-01", "date_end" => "2025-08-02"))
      .to_return(
        body: {
          results: [
            { "date" => "2025-08-01", "sunrise" => "6:10 AM", "sunset" => "8:20 PM", "golden_hour" => "7:30 PM", "timezone" => "Europe/Lisbon" },
            { "date" => "2025-08-02", "sunrise" => "6:11 AM", "sunset" => "8:19 PM", "golden_hour" => "7:29 PM", "timezone" => "Europe/Lisbon" }
          ],
          status: "OK"
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    result = @service.fetch_range(lat: 38.7223, lng: -9.1393, date_start: "2025-08-01", date_end: "2025-08-02")

    assert_equal 2, result.size
    assert_equal Date.parse("2025-08-01"), result[0][:date]
    assert_equal "6:10 AM", result[0][:sunrise]
    assert_equal "8:20 PM", result[0][:sunset]
    assert_equal "7:30 PM", result[0][:golden_hour]
    assert_equal "Europe/Lisbon", result[0][:timezone]
  end

  test "fetch_range raises ApiFailureError when API returns non-OK status" do
    stub_request(:get, %r{api\.sunrisesunset\.io})
      .to_return(body: { status: "INVALID_REQUEST" }.to_json, status: 200)

    error = assert_raises(SunriseSunsetApiService::ApiFailureError) do
      @service.fetch_range(lat: 38.72, lng: -9.13, date_start: "2025-08-01", date_end: "2025-08-01")
    end
    assert_match(/API error/, error.message)
  end

  test "fetch_range raises ApiFailureError when HTTP is not success" do
    stub_request(:get, %r{api\.sunrisesunset\.io})
      .to_return(status: 500, body: "error")

    error = assert_raises(SunriseSunsetApiService::ApiFailureError) do
      @service.fetch_range(lat: 38.72, lng: -9.13, date_start: "2025-08-01", date_end: "2025-08-01")
    end
    assert_match(/500/, error.message)
  end
end
