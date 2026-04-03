class Mutations::DeleteCoffeeShop < Mutations::BaseMutation
    null false
    argument :id, ID

    field :coffee_shop, Types::CoffeeShop
    field :errors, [String], null: false

    def resolve(id:)
        coffee_shop = CoffeeShop.find_by(id: id)
        return { coffee_shop: nil, errors: ["Coffee shop not found"] } unless coffee_shop

        if coffee_shop.destroy
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