require "csv"

class CsvParser
  def self.parse(csv_body)
    csv_body.lines.filter_map.with_index(1) do |line, idx|
      row = parse_line(line, idx)
      next unless row

      build_shop(row, idx)
    end
  end

  def self.parse_line(line, idx)
    row = CSV.parse_line(line)
    return nil if row.nil? || row.compact.empty?

    if row.length < 3
      Rails.logger.warn "Skipping malformed CSV row #{idx}: #{row.inspect}"
      return nil
    end

    row
  rescue CSV::MalformedCSVError => e
    Rails.logger.warn "Skipping malformed CSV row #{idx}: #{e.message}"
    nil
  end

  def self.build_shop(row, idx)
    name = row[0]&.strip
    x = CoordinateParser.parse(row[1]&.strip)
    y = CoordinateParser.parse(row[2]&.strip)

    if name.nil? || name.empty? || x.nil? || y.nil?
      Rails.logger.warn "Skipping malformed CSV row #{idx}: #{row.inspect}"
      return nil
    end

    CoffeeShop.new(id: idx, name: name, x: x, y: y)
  end

  private_class_method :parse_line, :build_shop
end
