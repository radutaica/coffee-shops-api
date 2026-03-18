require "rails_helper"

RSpec.describe "GET /api/v1/coffee_shops", type: :request do
  let(:csv_body) do
    <<~CSV
      Starbucks Seattle2,47.5788,122.3974
      Starbucks Seattle,47.5869,122.4236
      Starbucks SF,37.5841,122.4011
    CSV
  end

  before do
    stub_request(:get, CsvFetcher::CSV_URL).to_return(body: csv_body)
  end

  it "sets Content-Type to application/vnd.api+json" do
    get "/api/v1/coffee_shops", params: { x: 47.6, y: -122.4 }
    expect(response.content_type).to include("application/vnd.api+json")
  end

  it "sets Content-Type to application/vnd.api+json on error responses" do
    get "/api/v1/coffee_shops", params: { x: "bad", y: -122.4 }
    expect(response.content_type).to include("application/vnd.api+json")
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

    it "returns distance rounded to 4 decimal places" do
      get "/api/v1/coffee_shops", params: { x: 47.6, y: -122.4 }

      json = JSON.parse(response.body)
      distance = json["data"].first["attributes"]["distance"]
      expect(distance).to eq(distance.round(4))
    end

    it "accepts integer string coordinates" do
      get "/api/v1/coffee_shops", params: { x: "47", y: "-122" }
      expect(response).to have_http_status(:ok)
    end

    it "returns only available shops when CSV has fewer than 3" do
      stub_request(:get, CsvFetcher::CSV_URL).to_return(body: "Only One,47.5,122.4\n")
      get "/api/v1/coffee_shops", params: { x: 47.6, y: -122.4 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(1)
    end

    it "returns empty data array when CSV has no valid rows" do
      stub_request(:get, CsvFetcher::CSV_URL).to_return(body: "")
      get "/api/v1/coffee_shops", params: { x: 47.6, y: -122.4 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]).to eq([])
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

    it "returns 422 when both x and y are missing" do
      get "/api/v1/coffee_shops"
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns JSON API error format on 422" do
      get "/api/v1/coffee_shops", params: { x: "bad", y: -122.4 }

      json = JSON.parse(response.body)
      expect(json["errors"].first).to include("status", "title")
      expect(json["errors"].first["status"]).to eq("422")
    end
  end

  context "when CSV fetch fails" do
    it "returns 503 when network is unavailable" do
      stub_request(:get, CsvFetcher::CSV_URL).to_raise(SocketError)
      get "/api/v1/coffee_shops", params: { x: 47.6, y: -122.4 }

      expect(response).to have_http_status(:service_unavailable)
    end

    it "returns JSON API error format on 503" do
      stub_request(:get, CsvFetcher::CSV_URL).to_raise(SocketError)
      get "/api/v1/coffee_shops", params: { x: 47.6, y: -122.4 }

      json = JSON.parse(response.body)
      expect(json["errors"].first).to include("status", "title")
      expect(json["errors"].first["status"]).to eq("503")
    end
  end
end
