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

  describe ".parse" do
    it "returns coffee shops with correct attributes" do
      shops = CsvParser.parse(csv_body)
      expect(shops.map(&:name)).to eq(["Starbucks Seattle", "Starbucks SF"])
    end

    it "skips rows with missing or non-numeric X/Y" do
      shops = CsvParser.parse(csv_body)
      expect(shops.size).to eq(2)
    end

    it "assigns ids based on row position" do
      shops = CsvParser.parse(csv_body)
      expect(shops.map(&:id)).to eq([1, 2])
    end

    it "skips rows with fewer than 3 columns" do
      short_row_csv = "Good Shop,1.0,2.0\nToo Short\n"
      shops = CsvParser.parse(short_row_csv)
      expect(shops.size).to eq(1)
      expect(shops.first.name).to eq("Good Shop")
    end

    it "returns empty array for empty CSV" do
      shops = CsvParser.parse("")
      expect(shops).to eq([])
    end

    it "returns CoffeeShop instances" do
      shops = CsvParser.parse(csv_body)
      expect(shops.first).to be_a(CoffeeShop)
    end

    it "ids are non-contiguous when rows are skipped" do
      csv = "Good,1.0,2.0\nBad,,\nAlso Good,3.0,4.0\n"
      shops = CsvParser.parse(csv)
      expect(shops.map(&:id)).to eq([1, 3])
    end
  end
end
