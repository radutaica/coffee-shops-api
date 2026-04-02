class CreateCoffeeShop < ActiveRecord::Migration[8.1]
  def change
    create_table :coffee_shops do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.string :opening_time, null: false
      t.string :closing_time, null: false
      t.float :x_coordinate, null: false
      t.float :y_coordinate, null: false
      t.timestamps
    end
  end
end
