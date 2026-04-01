module CoordinateParser
  def self.parse(value)
    return nil if value.nil?
    return nil if value.is_a?(Array)

    float = Float(value)
    float.finite? ? float : nil
  rescue ArgumentError, TypeError
    nil
  end
end
