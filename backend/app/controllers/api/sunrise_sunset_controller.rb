# frozen_string_literal: true

module Api
  class SunriseSunsetController < Api::BaseController
    def show
      location = params[:location].to_s.strip
      if location.blank?
        return render json: { error: "Missing or empty location" }, status: :unprocessable_entity
      end

      repo = SunriseSunsetRepository.new
      result = repo.find_or_fetch(
        location_name: location,
        start_date: params[:start_date],
        end_date: params[:end_date],
        limit: params[:limit],
        page: params[:page]
      )
      # Header: database = all from DB, api = all from API, "database,api" = both
      response.headers["X-Sunrise-Source"] = result[:source]
      render json: result
    end
  end
end
