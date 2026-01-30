# frozen_string_literal: true

# Resolves location names to (lat, lng) for SunriseSunset.io API.
# Hardcoded list — no external geocoding. Add entries as needed.
# Polar entries: API may return null for sunrise/sunset (polar night / midnight sun).
class LocationGeocoder
  # Normalized name (downcased, stripped) => [lat, lng]
  LOCATIONS = {
    "lisboa" => [38.7223, -9.1393],
    "lisbon" => [38.7223, -9.1393],
    "berlin" => [52.5200, 13.4050],
    "london" => [51.5074, -0.1278],
    "new york" => [40.7128, -74.0060],
    "londres" => [51.5074, -0.1278],
    "porto" => [41.1579, -8.6291],
    "madrid" => [40.4168, -3.7038],
    "paris" => [48.8566, 2.3522],
    "amsterdam" => [52.3676, 4.9041],
    "tokyo" => [35.6762, 139.6503],
    "sydney" => [-33.8688, 151.2093],
    # Polar — API can return null for sunrise/sunset in some months
    "north pole" => [90.0, 0.0],
    "south pole" => [-90.0, 0.0],
    "longyearbyen" => [78.2232, 15.6267],   # Svalbard: polar night Dec–Jan, midnight sun Apr–Aug
    "alert" => [82.5017, -62.3481],        # Canada, northernmost settlement
    "mcmurdo" => [-77.8467, 166.6763],     # Antarctica research station
  }.freeze

  def coordinates_for(query)
    return nil if query.blank?
    key = query.to_s.strip.downcase
    return nil if key.empty?

    LOCATIONS[key]
  end
end
