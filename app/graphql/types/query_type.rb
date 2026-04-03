# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :coffee_shops, [ Types::CoffeeShop ], null: false do
      argument :y, Float, required: true
      argument :x, Float, required: true
      argument :name, String, required: false, default_value: nil
    end

    def coffee_shops(x:, y:, name:)
      shops = ::CoffeeShop.all
      shops = shops.where("name LIKE ?", "%#{name}%") if name.present?
      CoffeeShopFinder.new(x: x, y: y, shops: shops).call
    end
  end
end
