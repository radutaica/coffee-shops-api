require "csv"

class CsvParser
  def self.parse(csv_body)
    lines = csv_body.lines
    lines.filter_map.with_index(1) do |line, idx|
      row = begin
        CSV.parse_line(line)
      rescue CSV::MalformedCSVError => e
        Rails.logger.warn "Skipping malformed CSV row #{idx}: #{e.message}"
        next
      end

      next if row.nil? || row.compact.empty?

      if row.length < 3
        Rails.logger.warn "Skipping malformed CSV row #{idx}: #{row.inspect}"
        next
      end

      name = row[0]&.strip
      x = Float(row[1]&.strip) rescue nil
      y = Float(row[2]&.strip) rescue nil

      if name.nil? || name.empty? || x.nil? || y.nil?
        Rails.logger.warn "Skipping malformed CSV row #{idx}: #{row.inspect}"
        next
      end

      CoffeeShop.new(id: idx, name: name, x: x, y: y)
    end
  end
end
