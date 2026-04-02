class DistanceCalculator
  def initialize(shops:, x:, y:)
    @shops = shops
    @x = x
    @y = y
  end

  def call
    @shops.each { |shop| shop.distance = calculate_distance(shop) }
    @shops.sort_by { |shop| [ shop.distance, shop.name ] }
  end

  private

  def calculate_distance(shop)
    Math.sqrt((shop.x_coordinate - @x)**2 + (shop.y_coordinate - @y)**2).round(4)
  end
end
