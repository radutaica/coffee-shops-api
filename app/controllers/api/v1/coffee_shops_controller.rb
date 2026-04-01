module Api
  module V1
    class CoffeeShopsController < ApplicationController
      def index
        errors = validate_coordinates
        if errors.any?
          return render json: { errors: errors }, status: :unprocessable_entity
        end

        finder = CoffeeShopFinder.new(x: @x, y: @y)
        render json: CoffeeShopSerializer.new(finder.call).serializable_hash
      rescue CsvFetcher::FetchError
        render json: {
          errors: [ { status: "503", title: "Service Unavailable", detail: "Unable to fetch coffee shop data" } ]
        }, status: :service_unavailable
      end

      private

      def validate_coordinates
        errors = []

        @x = CoordinateParser.parse(params[:x])
        errors << { status: "422", title: "Invalid Parameter", detail: "x is required and must be a valid number" } if @x.nil?

        @y = CoordinateParser.parse(params[:y])
        errors << { status: "422", title: "Invalid Parameter", detail: "y is required and must be a valid number" } if @y.nil?

        errors
      end
    end
  end
end
