class CoffeeShopFinder
  DEFAULT_LIMIT = 3

  def initialize(x:, y:, limit: DEFAULT_LIMIT)
    @x = x
    @y = y
    @limit = limit
  end

  def call
    csv_body = CsvFetcher.new.call
    shops = CsvParser.new(csv_body).call
    DistanceCalculator.new(shops: shops, x: @x, y: @y, limit: @limit).call
  end
end
