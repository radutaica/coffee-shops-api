require "rails_helper"

RSpec.describe CsvFetcher do
  let(:csv_body) do
    <<~CSV
      Starbucks Seattle,47.5809,122.4177
      Starbucks SF,37.5841,122.4011
    CSV
  end

  describe "#call" do
    it "fetches the remote CSV body" do
      stub_request(:get, CsvFetcher::CSV_URL).to_return(body: csv_body)
      result = described_class.new.call
      expect(result).to be_a(String)
      expect(result).to include("Starbucks Seattle")
    end

    it "raises FetchError on SocketError" do
      stub_request(:get, CsvFetcher::CSV_URL).to_raise(SocketError)
      expect { described_class.new.call }.to raise_error(CsvFetcher::FetchError)
    end

    it "raises FetchError on HTTP 500" do
      stub_request(:get, CsvFetcher::CSV_URL).to_return(status: 500, body: "Internal Server Error")
      expect { described_class.new.call }.to raise_error(CsvFetcher::FetchError, "HTTP 500")
    end

    it "does not make a second HTTP request when cache is warm" do
      stub = stub_request(:get, CsvFetcher::CSV_URL).to_return(body: csv_body)
      described_class.new.call
      described_class.new.call
      expect(stub).to have_been_requested.once
    end

    it "raises FetchError on Timeout::Error" do
      stub_request(:get, CsvFetcher::CSV_URL).to_raise(Timeout::Error)
      expect { described_class.new.call }.to raise_error(CsvFetcher::FetchError)
    end

    it "raises FetchError when CSV URL returns HTML 404 page" do
      stub_request(:get, CsvFetcher::CSV_URL).to_return(status: 404, body: "<html><body>Not Found</body></html>")
      expect { described_class.new.call }.to raise_error(CsvFetcher::FetchError, "HTTP 404")
    end
  end
end
