require "rails_helper"

RSpec.describe "GET /health", type: :request do
  it "returns 200 OK" do
    get "/health"
    expect(response).to have_http_status(:ok)
  end

  it "returns status ok in body" do
    get "/health"
    json = JSON.parse(response.body)
    expect(json["status"]).to eq("ok")
  end

  it "sets Content-Type to application/vnd.api+json" do
    get "/health"
    expect(response.content_type).to include("application/vnd.api+json")
  end
end
