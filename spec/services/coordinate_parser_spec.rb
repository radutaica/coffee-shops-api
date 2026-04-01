require "rails_helper"

RSpec.describe CoordinateParser do
  describe ".parse" do
    it "parses a valid float string" do
      expect(described_class.parse("47.6")).to eq(47.6)
    end

    it "parses an integer string" do
      expect(described_class.parse("47")).to eq(47.0)
    end

    it "parses negative numbers" do
      expect(described_class.parse("-122.4")).to eq(-122.4)
    end

    it "returns nil for nil" do
      expect(described_class.parse(nil)).to be_nil
    end

    it "returns nil for empty string" do
      expect(described_class.parse("")).to be_nil
    end

    it "returns nil for non-numeric string" do
      expect(described_class.parse("abc")).to be_nil
    end

    it "returns nil for Infinity via extreme exponent" do
      expect(described_class.parse("1e999")).to be_nil
    end

    it "returns nil for array injection" do
      expect(described_class.parse([ "1" ])).to be_nil
    end

    it "parses a valid float value" do
      expect(described_class.parse(47.6)).to eq(47.6)
    end
  end
end
