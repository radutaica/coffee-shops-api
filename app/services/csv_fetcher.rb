require "httparty"

class CsvFetcher
  CSV_URL = ENV.fetch("COFFEE_SHOPS_CSV_URL", "https://raw.githubusercontent.com/Agilefreaks/test_oop/master/coffee_shops.csv")

  FetchError = Class.new(StandardError)

  def self.fetch
    response = HTTParty.get(CSV_URL, timeout: 5)
    raise FetchError, "HTTP #{response.code}" unless response.success?

    response.body
  rescue HTTParty::Error, SocketError, Timeout::Error => e
    raise FetchError, e.message
  end
end
