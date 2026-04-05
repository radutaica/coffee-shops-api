require "rails_helper"

RSpec.describe CoffeeShopFinder do
  let(:shops) do
    [
      CoffeeShop.new(name: "Starbucks Seattle2", x_coordinate: 47.5869, y_coordinate: -122.3368),
      CoffeeShop.new(name: "Starbucks Seattle", x_coordinate: 47.5809, y_coordinate: -122.3160),
      CoffeeShop.new(name: "Starbucks SF", x_coordinate: 37.5209, y_coordinate: -122.3340)
    ]
  end

  describe "#call" do
    it "returns shops sorted by distance" do
      result = described_class.new(x: 47.6, y: -122.4, shops: shops).call
      expect(result.map(&:name)).to eq([ "Starbucks Seattle2", "Starbucks Seattle", "Starbucks SF" ])
    end

    it "returns results with distance attribute" do
      result = described_class.new(x: 47.6, y: -122.4, shops: shops).call
      expect(result.first).to respond_to(:distance)
      expect(result.first.distance).to be_a(Float)
    end
  end
end
