class CoffeeShopSerializer
  include JSONAPI::Serializer

  set_type :coffee_shop
  attributes :name, :x, :y, :distance
end
