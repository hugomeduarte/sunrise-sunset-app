# frozen_string_literal: true

# Resolves location names to (lat, lng). Hardcoded list; polar locations may yield null sunrise/sunset from API.
class LocationGeocoder
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
    "north pole" => [64.750623,-147.350777],
    "south pole" => [-90.0, 0.0],
    "longyearbyen" => [78.2232, 15.6267],
    "alert" => [82.5017, -62.3481],
    "mcmurdo" => [-77.8467, 166.6763],
  }.freeze

  def coordinates_for(query)
    return nil if query.blank?
    key = query.to_s.strip.downcase
    return nil if key.empty?

    LOCATIONS[key]
  end
end
