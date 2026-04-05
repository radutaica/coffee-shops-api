require "rails_helper"

RSpec.describe DistanceCalculator do
  let(:shops) do
    [
      CoffeeShop.new(id: 1, name: "Far",    x_coordinate: 100.0, y_coordinate: 100.0),
      CoffeeShop.new(id: 2, name: "Close",  x_coordinate: 1.0,   y_coordinate: 1.0),
      CoffeeShop.new(id: 3, name: "Medium", x_coordinate: 10.0,  y_coordinate: 10.0),
      CoffeeShop.new(id: 4, name: "Closer", x_coordinate: 2.0,   y_coordinate: 2.0)
    ]
  end

  describe "#call" do
    it "returns all shops sorted by distance" do
      result = described_class.new(shops: shops, x: 0, y: 0).call
      expect(result.map(&:name)).to eq([ "Close", "Closer", "Medium", "Far" ])
    end

    it "attaches distance to each result" do
      result = described_class.new(shops: shops, x: 0, y: 0).call
      expected = Math.sqrt(1.0**2 + 1.0**2).round(4)
      expect(result.first.distance).to eq(expected)
    end

    it "returns all shops when fewer than limit exist" do
      two_shops = shops.first(2)
      result = described_class.new(shops: two_shops, x: 0, y: 0).call
      expect(result.size).to eq(2)
    end

    it "returns empty array when shops list is empty" do
      result = described_class.new(shops: [], x: 0, y: 0).call
      expect(result).to eq([])
    end

    it "assigns distance 0.0 to a shop at the user's exact location" do
      shops_with_exact = [ CoffeeShop.new(id: 1, name: "Here", x_coordinate: 5.0, y_coordinate: 5.0) ]
      result = described_class.new(shops: shops_with_exact, x: 5.0, y: 5.0).call
      expect(result.first.distance).to eq(0.0)
    end

    it "breaks distance ties by name ascending" do
      equidistant_shops = [
        CoffeeShop.new(id: 1, name: "Gamma", x_coordinate: 1.0, y_coordinate: 0.0),
        CoffeeShop.new(id: 2, name: "Alpha", x_coordinate: -1.0, y_coordinate: 0.0),
        CoffeeShop.new(id: 3, name: "Beta",  x_coordinate: 0.0, y_coordinate: 1.0)
      ]
      result = described_class.new(shops: equidistant_shops, x: 0, y: 0).call
      expect(result.map(&:distance).uniq.size).to eq(1)
      expect(result.map(&:name)).to eq([ "Alpha", "Beta", "Gamma" ])
    end

    it "calculates Euclidean distance rounded to 4 decimal places" do
      shop = [ CoffeeShop.new(id: 1, name: "Test", x_coordinate: 3.0, y_coordinate: 4.0) ]
      result = described_class.new(shops: shop, x: 0, y: 0).call
      expect(result.first.distance).to eq(5.0)
    end

    it "rounds to 4 decimal places" do
      shop = [ CoffeeShop.new(id: 1, name: "Test", x_coordinate: 47.5809, y_coordinate: -122.4177) ]
      result = described_class.new(shops: shop, x: 47.6, y: -122.4).call
      expect(result.first.distance).to eq(result.first.distance.round(4))
    end

    it "returns exactly 4 decimal places, not 3" do
      shop = [ CoffeeShop.new(id: 1, name: "Test", x_coordinate: 1.23456, y_coordinate: 0.0) ]
      result = described_class.new(shops: shop, x: 0, y: 0).call
      expect(result.first.distance).to eq(1.2346)
      expect(result.first.distance).not_to eq(1.235)
    end

    it "returns exactly 4 decimal places, not 5" do
      shop = [ CoffeeShop.new(id: 1, name: "Test", x_coordinate: 1.23456, y_coordinate: 0.0) ]
      result = described_class.new(shops: shop, x: 0, y: 0).call
      expect(result.first.distance).to eq(1.2346)
      expect(result.first.distance).not_to eq(1.23456)
    end

    it "works with negative coordinates" do
      shop = [ CoffeeShop.new(id: 1, name: "Test", x_coordinate: -3.0, y_coordinate: -4.0) ]
      result = described_class.new(shops: shop, x: 0, y: 0).call
      expect(result.first.distance).to eq(5.0)
    end

    it "highlights the first 3 closest shops" do
      result = described_class.new(shops: shops, x: 0, y: 0).call
      expect(result[0].highlighted).to be true
      expect(result[1].highlighted).to be true
      expect(result[2].highlighted).to be true
      expect(result[3].highlighted).to be false
    end
  end
end
