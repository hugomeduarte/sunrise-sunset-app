# frozen_string_literal: true

require "test_helper"

module Api
  class SunriseSunsetControllerTest < ActionDispatch::IntegrationTest
    # Location lookup is hardcoded (LocationGeocoder::LOCATIONS); no Nominatim stubs needed.

    test "GET api/sunrise_sunset with valid params returns JSON" do
      stub_sunrisesunset_io(
        lat: 38.7223, lng: -9.1393,
        date_start: "2025-08-01", date_end: "2025-08-02",
        body: {
          results: [
            { date: "2025-08-01", sunrise: "6:10 AM", sunset: "8:20 PM", golden_hour: "7:30 PM", timezone: "Europe/Lisbon" },
            { date: "2025-08-02", sunrise: "6:11 AM", sunset: "8:19 PM", golden_hour: "7:29 PM", timezone: "Europe/Lisbon" }
          ],
          status: "OK"
        }
      )

      get api_sunrise_sunset_path, params: { location: "Lisbon", start_date: "2025-08-01", end_date: "2025-08-02" }

      assert_response :success
      json = response.parsed_body
      assert_equal "Lisbon", json["location"]
      assert_equal "2025-08-01", json["start_date"]
      assert_equal "2025-08-02", json["end_date"]
      assert_equal 2, json["data"].size
      assert_equal "2025-08-01", json["data"][0]["date"]
      assert_equal "6:10 AM", json["data"][0]["sunrise"]
      assert_equal "8:20 PM", json["data"][0]["sunset"]
      assert_equal "7:30 PM", json["data"][0]["golden_hour"]
    end

    test "GET api/sunrise_sunset with missing location returns 422" do
      get api_sunrise_sunset_path, params: { start_date: "2025-08-01", end_date: "2025-08-02" }

      assert_response :unprocessable_entity
      json = response.parsed_body
      assert_equal "Missing or empty location", json["error"]
    end

    test "GET api/sunrise_sunset with empty location returns 422" do
      get api_sunrise_sunset_path, params: { location: "   ", start_date: "2025-08-01", end_date: "2025-08-02" }

      assert_response :unprocessable_entity
    end

    test "GET api/sunrise_sunset with invalid location returns 404" do
      get api_sunrise_sunset_path, params: { location: "NowhereXYZ123", start_date: "2025-08-01", end_date: "2025-08-02" }

      assert_response :not_found
      json = response.parsed_body
      assert_match(/Location not found/, json["error"])
    end

    test "GET api/sunrise_sunset with missing start_date returns 422" do
      get api_sunrise_sunset_path, params: { location: "Lisbon", end_date: "2025-08-02" }

      assert_response :unprocessable_entity
      json = response.parsed_body
      assert_match(/Missing start_date or end_date|Invalid date/, json["error"])
    end

    test "GET api/sunrise_sunset with invalid date range returns 422" do
      get api_sunrise_sunset_path, params: { location: "Lisbon", start_date: "2025-08-10", end_date: "2025-08-01" }

      assert_response :unprocessable_entity
      json = response.parsed_body
      assert_match(/start_date must be before|Invalid date/, json["error"])
    end

    test "second request for same location and range uses DB (no extra API call)" do
      stub_sunrisesunset_io(
        lat: 38.7223, lng: -9.1393,
        date_start: "2025-08-05", date_end: "2025-08-05",
        body: {
          results: [{ date: "2025-08-05", sunrise: "6:00 AM", sunset: "8:00 PM", golden_hour: "7:00 PM", timezone: "Europe/Lisbon" }],
          status: "OK"
        }
      )

      get api_sunrise_sunset_path, params: { location: "Lisbon", start_date: "2025-08-05", end_date: "2025-08-05" }
      assert_response :success

      # Same request again: should not call SunriseSunset.io (data from DB). If it did, we'd get 502.
      WebMock.reset!
      stub_request(:get, %r{api\.sunrisesunset\.io}).to_return(status: 500, body: "error")

      get api_sunrise_sunset_path, params: { location: "Lisbon", start_date: "2025-08-05", end_date: "2025-08-05" }
      assert_response :success

      json = response.parsed_body
      assert_equal 1, json["data"].size
      assert_equal "6:00 AM", json["data"][0]["sunrise"]
    end

    private

    def stub_sunrisesunset_io(lat:, lng:, date_start:, date_end:, body:)
      stub_request(:get, "https://api.sunrisesunset.io/json")
        .with(query: hash_including("lat" => lat.to_s, "lng" => lng.to_s, "date_start" => date_start, "date_end" => date_end))
        .to_return(body: body.to_json, headers: { "Content-Type" => "application/json" })
    end
  end
end
