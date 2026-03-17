class CoffeeShop
  attr_reader :id, :name, :x, :y

  def initialize(id:, name:, x:, y:)
    @id = id
    @name = name
    @x = x
    @y = y
  end
end
