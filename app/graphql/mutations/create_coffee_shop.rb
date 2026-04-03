class Mutations::CreateCoffeeShop < Mutations::BaseMutation
  null false
  argument :name, String
  argument :address, String
  argument :opening_time, String
  argument :closing_time, String
  argument :x, Float
  argument :y, Float

  field :coffee_shop, Types::CoffeeShop
  field :errors, [String], null: false

  def resolve(name:, address:, opening_time:, closing_time:, x:, y:)
    coffee_shop = CoffeeShop.new(name: name, address: address, opening_time: opening_time, closing_time: closing_time, x_coordinate: x, y_coordinate: y)
    if coffee_shop.save
      {
        coffee_shop: coffee_shop,
        errors: [],
      }
    else
      {
        coffee_shop: nil,
        errors: coffee_shop.errors.full_messages
      }
    end
  end
end