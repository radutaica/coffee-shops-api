# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :coffee_shops, [Types::CoffeeShop], null: false do 
      argument :y, Float, required: true 
      argument :x, Float, required: true
    end

    def coffee_shops(x:, y:)
      shops = ::CoffeeShop.all
      CoffeeShopFinder.new(x: x, y: y, shops: shops).call
    end
  end
end
