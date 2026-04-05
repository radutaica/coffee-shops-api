require "rails_helper"

RSpec.describe "GraphQL mutation authentication", type: :request do
  let(:mutation) do
    <<~GQL
      mutation($input: CreateCoffeeShopInput!) {
        createCoffeeShop(input: $input) {
          coffeeShop { id }
          errors
        }
      }
    GQL
  end

  let(:variables) do
    {
      input: {
        name: "Auth Test",
        address: "123 Auth St",
        openingTime: "08:00",
        closingTime: "22:00",
        x: 1.0,
        y: 2.0
      }
    }
  end

  it "rejects mutations without an Authorization header" do
    expect {
      post "/graphql",
        params: { query: mutation, variables: variables }.to_json,
        headers: graphql_headers_without_auth
    }.not_to change(CoffeeShop, :count)

    json = JSON.parse(response.body)
    expect(json["errors"]).to be_present
    expect(json["errors"].first["message"]).to match(/authentication required/i)
  end

  it "rejects mutations with an invalid API key" do
    expect {
      post "/graphql",
        params: { query: mutation, variables: variables }.to_json,
        headers: graphql_headers(api_key: "invalid-key")
    }.not_to change(CoffeeShop, :count)

    json = JSON.parse(response.body)
    expect(json["errors"]).to be_present
    expect(json["errors"].first["message"]).to match(/authentication required/i)
  end

  it "allows mutations with a valid API key" do
    expect {
      post "/graphql",
        params: { query: mutation, variables: variables }.to_json,
        headers: graphql_headers
    }.to change(CoffeeShop, :count).by(1)

    json = JSON.parse(response.body)
    expect(json["data"]["createCoffeeShop"]["errors"]).to be_empty
  end
end
