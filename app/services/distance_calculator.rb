class DistanceCalculator
  Result = Struct.new(:id, :name, :x, :y, :distance)

  def initialize(shops:, x:, y:, limit: 3)
    @shops = shops
    @x = x
    @y = y
    @limit = limit
  end

  def call
    @shops
      .map { |shop| [ shop, calculate_distance(shop) ] }
      .sort_by { |shop, dist| [ dist, shop.name ] }
      .first(@limit)
      .map { |shop, dist| Result.new(shop.id, shop.name, shop.x_coordinate, shop.y_coordinate, dist) }
  end

  private

  def calculate_distance(shop)
    Math.sqrt((shop.x_coordinate - @x)**2 + (shop.y_coordinate - @y)**2).round(4)
  end
end
