require "httparty"
require "csv"

class CsvFetcher
  CSV_URL = "https://raw.githubusercontent.com/Agilefreaks/test_oop/master/coffee_shops.csv"

  CoffeeShop = Struct.new(:id, :name, :x, :y)
  FetchError = Class.new(StandardError)

  def self.fetch
    response = HTTParty.get(CSV_URL, timeout: 5)
    raise FetchError, "HTTP #{response.code}" unless response.success?
    parse(response.body)
  rescue HTTParty::Error, SocketError, Timeout::Error => e
    raise FetchError, e.message
  end

  def self.parse(csv_body)
    rows = CSV.parse(csv_body)
    rows.filter_map.with_index(1) do |row, idx|
      next if row.length < 3
      x = Float(row[1]) rescue nil
      y = Float(row[2]) rescue nil
      next if x.nil? || y.nil?

      CoffeeShop.new(idx, row[0], x, y)
    end
  end
end
