class CoffeeShopFinder

  def initialize(x:, y:, shops:)
    @x = x
    @y = y
    @shops = shops
  end

  def call
    DistanceCalculator.new(shops: @shops, x: @x, y: @y).call
  end
end
