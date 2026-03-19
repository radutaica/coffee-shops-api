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
        CoffeeShop.new(id: 1, name: "Far",    x: 100.0, y: 100.0),
        CoffeeShop.new(id: 2, name: "Close",  x: 1.0,   y: 1.0),
        CoffeeShop.new(id: 3, name: "Medium", x: 10.0,  y: 10.0),
        CoffeeShop.new(id: 4, name: "Closer", x: 2.0,   y: 2.0),
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
      shops_with_exact = [CoffeeShop.new(id: 1, name: "Here", x: 5.0, y: 5.0)]
      result = DistanceCalculator.closest(shops_with_exact, 5.0, 5.0, limit: 3)
      expect(result.first.distance).to eq(0.0)
    end

    it "breaks distance ties by name ascending" do
      equidistant_shops = [
        CoffeeShop.new(id: 1, name: "Gamma", x: 1.0, y: 0.0),
        CoffeeShop.new(id: 2, name: "Alpha", x: -1.0, y: 0.0),
        CoffeeShop.new(id: 3, name: "Beta",  x: 0.0, y: 1.0),
      ]
      result = DistanceCalculator.closest(equidistant_shops, 0, 0, limit: 3)
      expect(result.map(&:distance).uniq.size).to eq(1)
      expect(result.map(&:name)).to eq(["Alpha", "Beta", "Gamma"])
    end
  end

  describe ".distance rounding precision" do
    it "returns exactly 4 decimal places, not 3" do
      result = DistanceCalculator.distance(0, 0, 1.23456, 0)
      expect(result).to eq(1.2346)
      expect(result).not_to eq(1.235)
    end

    it "returns exactly 4 decimal places, not 5" do
      result = DistanceCalculator.distance(0, 0, 1.23456, 0)
      expect(result).to eq(1.2346)
      expect(result).not_to eq(1.23456)
    end
  end
end
