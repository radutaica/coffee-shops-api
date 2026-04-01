require "rails_helper"

RSpec.describe CsvParser do
  let(:csv_body) do
    <<~CSV
      Starbucks Seattle,47.5809,122.4177
      Starbucks SF,37.5841,122.4011
      Bad Row,,
      Also Bad,foo,bar
    CSV
  end

  describe "#call" do
    it "returns coffee shops with correct attributes" do
      shops = described_class.new(csv_body).call
      expect(shops.map(&:name)).to eq([ "Starbucks Seattle", "Starbucks SF" ])
    end

    it "skips rows with missing or non-numeric X/Y" do
      shops = described_class.new(csv_body).call
      expect(shops.size).to eq(2)
    end

    it "assigns ids based on row position" do
      shops = described_class.new(csv_body).call
      expect(shops.map(&:id)).to eq([ 1, 2 ])
    end

    it "skips rows with fewer than 3 columns" do
      short_row_csv = "Good Shop,1.0,2.0\nToo Short\n"
      shops = described_class.new(short_row_csv).call
      expect(shops.size).to eq(1)
      expect(shops.first.name).to eq("Good Shop")
    end

    it "returns empty array for empty CSV" do
      shops = described_class.new("").call
      expect(shops).to eq([])
    end

    it "returns CoffeeShop instances" do
      shops = described_class.new(csv_body).call
      expect(shops.first).to be_a(CoffeeShop)
    end

    it "ids are non-contiguous when rows are skipped" do
      csv = "Good,1.0,2.0\nBad,,\nAlso Good,3.0,4.0\n"
      shops = described_class.new(csv).call
      expect(shops.map(&:id)).to eq([ 1, 3 ])
    end

    it "strips whitespace from name, x, and y values" do
      csv = "  Starbucks  , 47.5809 , 122.4177 \n"
      shops = described_class.new(csv).call
      expect(shops.first.name).to eq("Starbucks")
      expect(shops.first.x).to eq(47.5809)
      expect(shops.first.y).to eq(122.4177)
    end

    it "skips the header row when present" do
      csv = "Name,X,Y\nStarbucks,47.5809,122.4177\n"
      shops = described_class.new(csv).call
      expect(shops.size).to eq(1)
      expect(shops.first.name).to eq("Starbucks")
    end

    it "logs a warning for each skipped malformed row" do
      allow(Rails.logger).to receive(:warn)
      described_class.new(csv_body).call
      expect(Rails.logger).to have_received(:warn).twice
    end

    it "logs a warning when a row has fewer than 3 columns" do
      allow(Rails.logger).to receive(:warn)
      described_class.new("Good,1.0,2.0\nToo Short\n").call
      expect(Rails.logger).to have_received(:warn).once
    end

    it "skips rows with malformed quoting instead of crashing" do
      csv = "Good Shop,1.0,2.0\nCafé \"The Best\",40.758,-73.9855\nAnother Good,3.0,4.0\n"
      shops = described_class.new(csv).call
      expect(shops.map(&:name)).to include("Good Shop", "Another Good")
    end

    it "logs a warning for rows with malformed quoting" do
      allow(Rails.logger).to receive(:warn)
      csv = "Good,1.0,2.0\nCafé \"The Best\",40.758,-73.9855\n"
      described_class.new(csv).call
      expect(Rails.logger).to have_received(:warn).at_least(:once)
    end

    it "skips rows with blank or missing name" do
      csv = ",47.5809,-122.3160\n  ,37.5841,-122.4011\nValid Shop,1.0,2.0\n"
      shops = described_class.new(csv).call
      expect(shops.size).to eq(1)
      expect(shops.first.name).to eq("Valid Shop")
    end

    it "handles Windows-style CRLF line endings" do
      csv = "Shop A,1.0,2.0\r\nShop B,3.0,4.0\r\n"
      shops = described_class.new(csv).call
      expect(shops.map(&:name)).to eq([ "Shop A", "Shop B" ])
    end

    it "handles mixed line endings" do
      csv = "Shop A,1.0,2.0\r\nShop B,3.0,4.0\nShop C,5.0,6.0\r\n"
      shops = described_class.new(csv).call
      expect(shops.map(&:name)).to eq([ "Shop A", "Shop B", "Shop C" ])
    end

    it "parses rows with a trailing comma" do
      csv = "Starbucks,47.5809,-122.316,\n"
      shops = described_class.new(csv).call
      expect(shops.size).to eq(1)
      expect(shops.first.name).to eq("Starbucks")
    end
  end
end
