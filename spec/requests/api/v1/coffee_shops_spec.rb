require "rails_helper"

RSpec.describe "GET /api/v1/coffee_shops", type: :request do
  let(:csv_body) do
    <<~CSV
      Starbucks Seattle2,47.5869,-122.3368
      Starbucks Seattle,47.5809,-122.3160
      Starbucks SF,37.5209,-122.3340
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
      expect(names).to eq([ "Starbucks Seattle2", "Starbucks Seattle", "Starbucks SF" ])
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

    it "ignores extra query params" do
      get "/api/v1/coffee_shops", params: { x: 47.6, y: -122.4, z: 99, foo: "bar" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(3)
    end

    it "returns results for extremely large coordinates" do
      get "/api/v1/coffee_shops", params: { x: 999_999_999, y: 999_999_999 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(3)
      json["data"].each do |shop|
        expect(shop["attributes"]["distance"]).to be > 0
      end
    end

    it "returns 2 shops when CSV has only 2 valid rows" do
      stub_request(:get, CsvFetcher::CSV_URL).to_return(body: "Shop A,1.0,2.0\nShop B,3.0,4.0\n")
      get "/api/v1/coffee_shops", params: { x: 0, y: 0 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(2)
    end

    it "returns empty data when CSV has only malformed rows" do
      malformed_csv = ",,\n,47.5809,-122.3160\nBad X,abc,-122.3\nStarbucks NaN,NaN,NaN\n"
      stub_request(:get, CsvFetcher::CSV_URL).to_return(body: malformed_csv)
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

    it "returns 422 when x is empty string" do
      get "/api/v1/coffee_shops", params: { x: "", y: "-122.4" }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 when y is empty string" do
      get "/api/v1/coffee_shops", params: { x: "47.6", y: "" }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns JSON API error format on 422" do
      get "/api/v1/coffee_shops", params: { x: "bad", y: -122.4 }

      json = JSON.parse(response.body)
      expect(json["errors"].first).to include("status", "title", "detail")
      expect(json["errors"].first["status"]).to eq("422")
    end

    it "returns per-field error for invalid x" do
      get "/api/v1/coffee_shops", params: { x: "bad", y: -122.4 }

      json = JSON.parse(response.body)
      expect(json["errors"].size).to eq(1)
      expect(json["errors"].first["detail"]).to include("x")
    end

    it "returns per-field error for invalid y" do
      get "/api/v1/coffee_shops", params: { x: 47.6, y: "bad" }

      json = JSON.parse(response.body)
      expect(json["errors"].size).to eq(1)
      expect(json["errors"].first["detail"]).to include("y")
    end

    it "returns errors for both x and y when both are invalid" do
      get "/api/v1/coffee_shops", params: { x: "bad", y: "bad" }

      json = JSON.parse(response.body)
      expect(json["errors"].size).to eq(2)
    end

    it "returns 422 for Infinity via extreme exponent" do
      get "/api/v1/coffee_shops", params: { x: "1e999", y: -122.4 }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  context "when CSV fetch fails" do
    it "returns 503 when network is unavailable" do
      stub_request(:get, CsvFetcher::CSV_URL).to_raise(SocketError)
      get "/api/v1/coffee_shops", params: { x: 47.6, y: -122.4 }

      expect(response).to have_http_status(:service_unavailable)
    end

    it "returns 503 when CSV URL returns HTTP 500" do
      stub_request(:get, CsvFetcher::CSV_URL).to_return(status: 500, body: "Internal Server Error")
      get "/api/v1/coffee_shops", params: { x: 47.6, y: -122.4 }

      expect(response).to have_http_status(:service_unavailable)
    end

    it "returns 503 when CSV URL returns HTML instead of CSV" do
      stub_request(:get, CsvFetcher::CSV_URL).to_return(status: 404, body: "<html><body>Not Found</body></html>")
      get "/api/v1/coffee_shops", params: { x: 47.6, y: -122.4 }

      expect(response).to have_http_status(:service_unavailable)
    end

    it "returns 503 on request timeout" do
      stub_request(:get, CsvFetcher::CSV_URL).to_raise(Timeout::Error)
      get "/api/v1/coffee_shops", params: { x: 47.6, y: -122.4 }

      expect(response).to have_http_status(:service_unavailable)
    end

    it "returns JSON API error format on 503" do
      stub_request(:get, CsvFetcher::CSV_URL).to_raise(SocketError)
      get "/api/v1/coffee_shops", params: { x: 47.6, y: -122.4 }

      json = JSON.parse(response.body)
      expect(json["errors"].first).to include("status", "title", "detail")
      expect(json["errors"].first["status"]).to eq("503")
    end
  end

  context "with wrong HTTP method" do
    it "returns 405 for POST requests" do
      post "/api/v1/coffee_shops", params: { x: 47.6, y: -122.4 }
      expect(response).to have_http_status(:not_found).or have_http_status(:method_not_allowed)
    end

    it "returns 405 for PUT requests" do
      put "/api/v1/coffee_shops/1"
      expect(response).to have_http_status(:not_found).or have_http_status(:method_not_allowed)
    end

    it "returns 405 for DELETE requests" do
      delete "/api/v1/coffee_shops/1"
      expect(response).to have_http_status(:not_found).or have_http_status(:method_not_allowed)
    end
  end
end
