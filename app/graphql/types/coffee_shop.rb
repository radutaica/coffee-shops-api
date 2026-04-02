class Types::CoffeeShop < GraphQL::Schema::Object
  field :id, ID
  field :name, String, null: false
  field :address, String, null: false
  field :opening_time, String, null: false
  field :closing_time, String, null: false
  field :x, Float, null: false
  field :y, Float, null: false
  field :distance, Float, null: false

  def x
    object.x_coordinate
  end

  def y
    object.y_coordinate
  end
end