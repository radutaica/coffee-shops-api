require "csv"

class CsvParser
  def self.parse(csv_body)
    rows = CSV.parse(csv_body)
    rows.filter_map.with_index(1) do |row, idx|
      next if row.length < 3

      x = Float(row[1]&.strip) rescue nil
      y = Float(row[2]&.strip) rescue nil
      next if x.nil? || y.nil?

      CoffeeShop.new(id: idx, name: row[0]&.strip, x: x, y: y)
    end
  end
end
