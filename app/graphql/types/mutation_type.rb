# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_coffee_shop, mutation: Mutations::CreateCoffeeShop
    field :delete_coffee_shop, mutation: Mutations::DeleteCoffeeShop
    field :update_coffee_shop, mutation: Mutations::UpdateCoffeeShop
  end
end
