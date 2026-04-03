require "rails_helper"

RSpec.describe "createCoffeeShop mutation", type: :request do
  let(:query) do
    <<~GQL
      mutation($input: CreateCoffeeShopInput!) {
        createCoffeeShop(input: $input) {
          coffeeShop {
            id
            name
            address
            closingTime
            openingTime
            x
            y
          }
          errors
        }
      }
    GQL
  end

  it "creates a coffee shop with valid input" do
    variables = {
      input: {
        name: "Test Coffee",
        address: "Str. Test 1",
        openingTime: "08:00",
        closingTime: "22:00",
        x: 47.6,
        y: 26.2
      }
    }

    expect {
      post "/graphql",
        params: { query: query, variables: variables }.to_json,
        headers: { "Content-Type" => "application/json" }
    }.to change(CoffeeShop, :count).by(1)

    json = JSON.parse(response.body)
    data = json["data"]["createCoffeeShop"]

    expect(data["errors"]).to be_empty
    expect(data["coffeeShop"]["name"]).to eq("Test Coffee")
    expect(data["coffeeShop"]["address"]).to eq("Str. Test 1")
  end

  it "returns a GraphQL error when required field is missing" do
    variables = {
      input: {
        address: "Str. Test 1",
        openingTime: "08:00",
        closingTime: "22:00",
        x: 47.6,
        y: 26.2
      }
    }

    post "/graphql",
      params: { query: query, variables: variables }.to_json,
      headers: { "Content-Type" => "application/json" }

    json = JSON.parse(response.body)
    expect(json["errors"]).to be_present
  end

  it "does not create a record when required field is missing" do
    variables = {
      input: {
        address: "Str. Test 1",
        openingTime: "08:00",
        closingTime: "22:00",
        x: 47.6,
        y: 26.2
      }
    }

    expect {
      post "/graphql",
        params: { query: query, variables: variables }.to_json,
        headers: { "Content-Type" => "application/json" }
    }.not_to change(CoffeeShop, :count)
  end
end
