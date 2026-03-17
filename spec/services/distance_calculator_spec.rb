require "rails_helper"

RSpec.describe DistanceCalculator do
  describe ".distance" do
    it "calculates Euclidean distance rounded to 4 decimal places" do
      expect(DistanceCalculator.distance(0, 0, 3, 4)).to eq(5.0)
    end

    it "rounds to 4 decimal places" do
      result = DistanceCalculator.distance(47.6, -122.4, 47.5809, -122.4177)
      expect(result).to eq(result.round(4))
    end

    it "returns 0.0 when coordinates are identical" do
      expect(DistanceCalculator.distance(1.5, 2.5, 1.5, 2.5)).to eq(0.0)
    end

    it "works with negative coordinates" do
      expect(DistanceCalculator.distance(0, 0, -3, -4)).to eq(5.0)
    end
  end

  describe ".closest" do
    let(:shops) do
      [
        CsvFetcher::CoffeeShop.new(1, "Far",    100.0, 100.0),
        CsvFetcher::CoffeeShop.new(2, "Close",  1.0,   1.0),
        CsvFetcher::CoffeeShop.new(3, "Medium", 10.0,  10.0),
        CsvFetcher::CoffeeShop.new(4, "Closer", 2.0,   2.0),
      ]
    end

    it "returns the 3 closest shops sorted by distance" do
      result = DistanceCalculator.closest(shops, 0, 0, limit: 3)
      expect(result.map(&:name)).to eq(["Close", "Closer", "Medium"])
    end

    it "attaches distance to each result" do
      result = DistanceCalculator.closest(shops, 0, 0, limit: 3)
      expect(result.first.distance).to eq(DistanceCalculator.distance(0, 0, 1.0, 1.0))
    end

    it "returns all shops when fewer than limit exist" do
      two_shops = shops.first(2)
      result = DistanceCalculator.closest(two_shops, 0, 0, limit: 3)
      expect(result.size).to eq(2)
    end

    it "returns empty array when shops list is empty" do
      result = DistanceCalculator.closest([], 0, 0, limit: 3)
      expect(result).to eq([])
    end

    it "assigns distance 0.0 to a shop at the user's exact location" do
      shops_with_exact = [CsvFetcher::CoffeeShop.new(1, "Here", 5.0, 5.0)]
      result = DistanceCalculator.closest(shops_with_exact, 5.0, 5.0, limit: 3)
      expect(result.first.distance).to eq(0.0)
    end
  end
end
