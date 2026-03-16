require "rails_helper"

RSpec.describe "GET /api/v1/coffee_shops", type: :request do
  let(:csv_body) do
    <<~CSV
      Name,X,Y
      Starbucks Seattle2,47.5788,122.3974
      Starbucks Seattle,47.5869,122.4236
      Starbucks SF,37.5841,122.4011
    CSV
  end

  before do
    stub_request(:get, CsvFetcher::CSV_URL).to_return(body: csv_body)
  end

  context "with valid coordinates" do
    it "returns 3 closest shops sorted closest to farthest" do
      get "/api/v1/coffee_shops", params: { x: 47.6, y: -122.4 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      names = json["data"].map { |d| d["attributes"]["name"] }
      expect(names).to eq(["Starbucks Seattle2", "Starbucks Seattle", "Starbucks SF"])
    end

    it "returns JSON API format" do
      get "/api/v1/coffee_shops", params: { x: 47.6, y: -122.4 }

      json = JSON.parse(response.body)
      expect(json).to have_key("data")
      expect(json["data"].first).to include("id", "type", "attributes")
      expect(json["data"].first["type"]).to eq("coffee_shop")
    end

    it "includes distance in attributes" do
      get "/api/v1/coffee_shops", params: { x: 47.6, y: -122.4 }

      json = JSON.parse(response.body)
      expect(json["data"].first["attributes"]).to have_key("distance")
    end
  end

  context "with missing or invalid params" do
    it "returns 422 when x is missing" do
      get "/api/v1/coffee_shops", params: { y: -122.4 }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 when y is non-numeric" do
      get "/api/v1/coffee_shops", params: { x: 47.6, y: "abc" }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
