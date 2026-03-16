class DistanceCalculator
  Result = Struct.new(:id, :name, :x, :y, :distance)

  def self.distance(x1, y1, x2, y2)
    Math.sqrt((x2 - x1)**2 + (y2 - y1)**2).round(4)
  end

  def self.closest(shops, x, y, limit: 3)
    shops
      .map { |shop| [ shop, distance(x, y, shop.x, shop.y) ] }
      .sort_by { |_, dist| dist }
      .first(limit)
      .map { |shop, dist| Result.new(shop.id, shop.name, shop.x, shop.y, dist) }
  end
end
