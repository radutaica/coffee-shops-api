require "rails_helper"

RSpec.describe CsvFetcher do
  let(:csv_body) do
    <<~CSV
      Name,X,Y
      Starbucks Seattle,47.5809,122.4177
      Starbucks SF,37.5841,122.4011
      Bad Row,,
      Also Bad,foo,bar
    CSV
  end

  describe ".parse" do
    it "returns coffee shops with correct attributes" do
      shops = CsvFetcher.parse(csv_body)
      expect(shops.map(&:name)).to eq(["Starbucks Seattle", "Starbucks SF"])
    end

    it "skips rows with missing or non-numeric X/Y" do
      shops = CsvFetcher.parse(csv_body)
      expect(shops.size).to eq(2)
    end

    it "assigns incrementing ids starting at 1" do
      shops = CsvFetcher.parse(csv_body)
      expect(shops.map(&:id)).to eq([1, 2])
    end
  end

  describe ".fetch" do
    it "fetches and parses the remote CSV" do
      stub_request(:get, CsvFetcher::CSV_URL).to_return(body: csv_body)
      shops = CsvFetcher.fetch
      expect(shops.size).to eq(2)
      expect(shops.first.name).to eq("Starbucks Seattle")
    end
  end
end
