require "rails_helper"

RSpec.describe "updateCoffeeShop mutation", type: :request do
  let(:query) do
    <<~GQL
      mutation($input: UpdateCoffeeShopInput!) {
        updateCoffeeShop(input: $input) {
          coffeeShop {
            id
            name
            address
            openingTime
            closingTime
            x
            y
          }
          errors
        }
      }
    GQL
  end

  let!(:coffee_shop) do
    CoffeeShop.create!(
      name: "Old Name",
      address: "Old Address",
      opening_time: "08:00",
      closing_time: "22:00",
      x_coordinate: 1.0,
      y_coordinate: 2.0
    )
  end

  it "updates a coffee shop with valid input" do
    variables = {
      input: {
        id: coffee_shop.id,
        name: "New Name"
      }
    }

    post "/graphql",
      params: { query: query, variables: variables }.to_json,
      headers: { "Content-Type" => "application/json" }

    json = JSON.parse(response.body)
    data = json["data"]["updateCoffeeShop"]

    expect(data["errors"]).to be_empty
    expect(data["coffeeShop"]["name"]).to eq("New Name")
    expect(data["coffeeShop"]["address"]).to eq("Old Address")
  end

  it "returns error when coffee shop not found" do
    variables = {
      input: {
        id: 999999,
        name: "New Name"
      }
    }

    post "/graphql",
      params: { query: query, variables: variables }.to_json,
      headers: { "Content-Type" => "application/json" }

    json = JSON.parse(response.body)
    data = json["data"]["updateCoffeeShop"]

    expect(data["coffeeShop"]).to be_nil
    expect(data["errors"]).to include("Coffee shop not found")
  end

  it "updates only the provided fields" do
    variables = {
      input: {
        id: coffee_shop.id,
        address: "New Address"
      }
    }

    post "/graphql",
      params: { query: query, variables: variables }.to_json,
      headers: { "Content-Type" => "application/json" }

    json = JSON.parse(response.body)
    data = json["data"]["updateCoffeeShop"]

    expect(data["errors"]).to be_empty
    expect(data["coffeeShop"]["name"]).to eq("Old Name")
    expect(data["coffeeShop"]["address"]).to eq("New Address")
    expect(data["coffeeShop"]["x"]).to eq(1.0)
    expect(data["coffeeShop"]["y"]).to eq(2.0)
  end
end
