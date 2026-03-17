class CoffeeShopFinder
  def initialize(x:, y:)
    @x = x
    @y = y
  end

  def call
    csv_body = CsvFetcher.fetch
    shops = CsvParser.parse(csv_body)
    DistanceCalculator.closest(shops, @x, @y, limit: 3)
  end
end
