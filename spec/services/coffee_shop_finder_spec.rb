require "rails_helper"

RSpec.describe CoffeeShopFinder do
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

  describe "#call" do
    it "returns the 3 closest shops sorted by distance" do
      result = CoffeeShopFinder.new(x: 47.6, y: -122.4).call
      expect(result.map(&:name)).to eq(["Starbucks Seattle2", "Starbucks Seattle", "Starbucks SF"])
    end

    it "returns results with distance attribute" do
      result = CoffeeShopFinder.new(x: 47.6, y: -122.4).call
      expect(result.first).to respond_to(:distance)
      expect(result.first.distance).to be_a(Float)
    end

    it "raises CsvFetcher::FetchError when CSV is unavailable" do
      stub_request(:get, CsvFetcher::CSV_URL).to_raise(SocketError)
      expect { CoffeeShopFinder.new(x: 47.6, y: -122.4).call }.to raise_error(CsvFetcher::FetchError)
    end
  end
end
