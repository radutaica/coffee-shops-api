require "rails_helper"

RSpec.describe "deleteCoffeeShop mutation", type: :request do
  let(:query) do
    <<~GQL
      mutation($input: DeleteCoffeeShopInput!) {
        deleteCoffeeShop(input: $input) {
          coffeeShop {
            id
            name
          }
          errors
        }
      }
    GQL
  end

  let!(:coffee_shop) do
    CoffeeShop.create!(
      name: "To Delete",
      address: "Some Address",
      opening_time: "08:00",
      closing_time: "22:00",
      x_coordinate: 1.0,
      y_coordinate: 2.0
    )
  end

  it "deletes a coffee shop" do
    variables = {
      input: {
        id: coffee_shop.id
      }
    }

    expect {
      post "/graphql",
        params: { query: query, variables: variables }.to_json,
        headers: graphql_headers
    }.to change(CoffeeShop, :count).by(-1)

    json = JSON.parse(response.body)
    data = json["data"]["deleteCoffeeShop"]

    expect(data["errors"]).to be_empty
    expect(data["coffeeShop"]["name"]).to eq("To Delete")
  end

  it "returns error when coffee shop not found" do
    variables = {
      input: {
        id: 999999
      }
    }

    post "/graphql",
      params: { query: query, variables: variables }.to_json,
      headers: graphql_headers

    json = JSON.parse(response.body)
    data = json["data"]["deleteCoffeeShop"]

    expect(data["coffeeShop"]).to be_nil
    expect(data["errors"]).to include("Coffee shop not found")
  end

  it "cannot delete the same coffee shop twice" do
    variables = { input: { id: coffee_shop.id } }

    post "/graphql",
      params: { query: query, variables: variables }.to_json,
      headers: graphql_headers

    post "/graphql",
      params: { query: query, variables: variables }.to_json,
      headers: graphql_headers

    json = JSON.parse(response.body)
    data = json["data"]["deleteCoffeeShop"]

    expect(data["coffeeShop"]).to be_nil
    expect(data["errors"]).to include("Coffee shop not found")
  end
end
