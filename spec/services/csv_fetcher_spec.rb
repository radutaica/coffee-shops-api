require "rails_helper"

RSpec.describe CsvFetcher do
  let(:csv_body) do
    <<~CSV
      Starbucks Seattle,47.5809,122.4177
      Starbucks SF,37.5841,122.4011
    CSV
  end

  describe ".fetch" do
    it "fetches the remote CSV body" do
      stub_request(:get, CsvFetcher::CSV_URL).to_return(body: csv_body)
      result = CsvFetcher.fetch
      expect(result).to be_a(String)
      expect(result).to include("Starbucks Seattle")
    end

    it "raises FetchError on SocketError" do
      stub_request(:get, CsvFetcher::CSV_URL).to_raise(SocketError)
      expect { CsvFetcher.fetch }.to raise_error(CsvFetcher::FetchError)
    end

    it "raises FetchError on HTTP 500" do
      stub_request(:get, CsvFetcher::CSV_URL).to_return(status: 500, body: "Internal Server Error")
      expect { CsvFetcher.fetch }.to raise_error(CsvFetcher::FetchError, "HTTP 500")
    end
  end
end
