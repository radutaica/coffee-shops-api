module Api
  module V1
    class CoffeeShopsController < ApplicationController
      def index
        x = Float(params[:x]) rescue nil
        y = Float(params[:y]) rescue nil

        if x.nil? || y.nil?
          return render json: { errors: [ { detail: "x and y must be valid numbers" } ] }, status: :unprocessable_entity
        end

        shops = CsvFetcher.fetch
        closest = DistanceCalculator.closest(shops, x, y, limit: 3)
        render json: CoffeeShopSerializer.new(closest).serializable_hash
      end
    end
  end
end
