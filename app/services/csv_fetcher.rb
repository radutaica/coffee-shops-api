require "httparty"

class CsvFetcher
  CSV_URL = ENV.fetch("COFFEE_SHOPS_CSV_URL", "https://raw.githubusercontent.com/Agilefreaks/test_oop/master/coffee_shops.csv")

  FetchError = Class.new(StandardError)

  def self.fetch
    Rails.cache.fetch("coffee_shops_csv", expires_in: 1.hour) do
      response = HTTParty.get(CSV_URL, timeout: 5)
      raise FetchError, "HTTP #{response.code}" unless response.success?

      response.body
    end
  rescue HTTParty::Error, SocketError, Timeout::Error => e
    raise FetchError, e.message
  end
end
