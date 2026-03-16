require "httparty"
require "csv"

class CsvFetcher
  CSV_URL = "https://raw.githubusercontent.com/Agilefreaks/test_oop/master/coffee_shops.csv"

  CoffeeShop = Struct.new(:id, :name, :x, :y)

  def self.fetch
    response = HTTParty.get(CSV_URL)
    parse(response.body)
  end

  def self.parse(csv_body)
    rows = CSV.parse(csv_body, headers: true)
    rows.filter_map.with_index(1) do |row, idx|
      x = Float(row["X"]) rescue nil
      y = Float(row["Y"]) rescue nil
      next if x.nil? || y.nil?

      CoffeeShop.new(idx, row["Name"], x, y)
    end
  end
end
