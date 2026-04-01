class CoffeeShopFinder
  def initialize(x:, y:)
    @x = x
    @y = y
  end

  def call
    csv_body = CsvFetcher.new.call
    shops = CsvParser.new(csv_body).call
    DistanceCalculator.new(shops: shops, x: @x, y: @y).call
  end
end
