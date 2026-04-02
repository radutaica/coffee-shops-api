CoffeeShop.destroy_all

csv_body = CsvFetcher.new.call
shops = CsvParser.new(csv_body).call

shops.each_with_index do |shop, i|
    CoffeeShop.create!(
        name: shop[:name],
        x_coordinate: shop[:x],
        y_coordinate: shop[:y],
        address: "#{100 + i} Avenue Street",
        opening_time: "06:00",
        closing_time: "#{16+i}:00"
    )
end