# frozen_string_literal: true

module Api
  class BaseController < ActionController::API
    rescue_from SunriseSunsetRepository::LocationNotFoundError, with: :location_not_found
    rescue_from SunriseSunsetRepository::InvalidDateRangeError, with: :unprocessable
    rescue_from SunriseSunsetRepository::ApiError, with: :external_api_error
    rescue_from SunriseSunsetApiService::ApiFailureError, with: :external_api_error

    private

    def location_not_found(exception)
      render json: { error: exception.message }, status: :not_found
    end

    def unprocessable(exception)
      render json: { error: exception.message }, status: :unprocessable_entity
    end

    def external_api_error(exception)
      render json: { error: "Sunrise/sunset service temporarily unavailable: #{exception.message}" }, status: :bad_gateway
    end
  end
end
