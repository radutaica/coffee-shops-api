class Mutations::UpdateCoffeeShop < Mutations::BaseMutation
    null false
    argument :id, ID
    argument :name, String, required: false
    argument :address, String, required: false
    argument :opening_time, String, required: false
    argument :closing_time, String, required: false
    argument :x, Float, required: false
    argument :y, Float, required: false

    field :coffee_shop, Types::CoffeeShop
    field :errors, [String], null: false

    def resolve(id:, name: nil, address: nil, opening_time: nil, closing_time: nil, x: nil, y: nil)
        coffee_shop = CoffeeShop.find_by(id: id)
        return { coffee_shop: nil, errors: ["Coffee shop not found"] } unless coffee_shop
        attributes = {name: name, address: address, opening_time: opening_time, closing_time: closing_time, x_coordinate: x, y_coordinate: y}.compact
        if coffee_shop.update(attributes)
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