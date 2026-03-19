module Api
  module V1
    class CoffeeShopsController < ApplicationController
      def index
        x = parse_float(params[:x])
        y = parse_float(params[:y])

        if x.nil? || y.nil?
          return render json: {
            errors: [ { status: "422", title: "Invalid Parameters", detail: "x and y must be valid numbers" } ]
          }, status: :unprocessable_entity
        end

        finder = CoffeeShopFinder.new(x: x, y: y)
        render json: CoffeeShopSerializer.new(finder.call).serializable_hash
      rescue CsvFetcher::FetchError
        render json: {
          errors: [ { status: "503", title: "Service Unavailable", detail: "Unable to fetch coffee shop data" } ]
        }, status: :service_unavailable
      end

      private

      def parse_float(value)
        Float(value)
      rescue ArgumentError, TypeError
        nil
      end
    end
  end
end
