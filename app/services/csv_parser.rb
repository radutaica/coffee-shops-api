require "csv"

class CsvParser
  def initialize(csv_body)
    @csv_body = csv_body
  end

  def call
    @csv_body.lines.filter_map.with_index(1) do |line, idx|
      row = parse_line(line, idx)
      next unless row

      build_shop(row, idx)
    end
  end

  private

  def parse_line(line, idx)
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

  def build_shop(row, idx)
    name = row[0]&.strip
    x = CoordinateParser.parse(row[1]&.strip)
    y = CoordinateParser.parse(row[2]&.strip)

    if name.nil? || name.empty? || x.nil? || y.nil?
      Rails.logger.warn "Skipping malformed CSV row #{idx}: #{row.inspect}"
      return nil
    end

    { name: name, x: x, y: y }
  end
end
