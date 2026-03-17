require "rails_helper"

RSpec.describe CoffeeShop do
  describe ".new" do
    it "stores id, name, x, y as readable attributes" do
      shop = CoffeeShop.new(id: 1, name: "Test Shop", x: 10.0, y: 20.0)

      expect(shop.id).to eq(1)
      expect(shop.name).to eq("Test Shop")
      expect(shop.x).to eq(10.0)
      expect(shop.y).to eq(20.0)
    end
  end
end
