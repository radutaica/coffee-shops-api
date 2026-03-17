require "csv"

class CsvParser
  def self.parse(csv_body)
    rows = CSV.parse(csv_body)
    rows.filter_map.with_index(1) do |row, idx|
      if row.length < 3
        Rails.logger.warn "Skipping malformed CSV row #{idx}: #{row.inspect}"
        next
      end

      x = Float(row[1]&.strip) rescue nil
      y = Float(row[2]&.strip) rescue nil

      if x.nil? || y.nil?
        Rails.logger.warn "Skipping malformed CSV row #{idx}: #{row.inspect}"
        next
      end

      CoffeeShop.new(id: idx, name: row[0]&.strip, x: x, y: y)
    end
  end
end
