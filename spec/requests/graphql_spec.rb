  require "rails_helper"                                                                                                                                                       
                                                                                                                                                                               
  RSpec.describe "GraphQL", type: :request do                                                                                                                                                  
    describe "coffeeShops query" do                                                                                                                                            
                                                                                                                                                                               
      let(:query) do                                                                                                                                                           
        <<~GQL                                                                                                                                                                 
          query($x: Float!, $y: Float!) {                                                                                                                                      
            coffeeShops(x: $x, y: $y) {
              id
              name
              address
              closingTime
              x                                                                                                                                                                
              y
              distance                                                                                                                                                         
            }     
          }
        GQL
      end

      it "returns shops sorted by distance" do
        CoffeeShop.create!(name: "Near Shop", x_coordinate: 1.0, y_coordinate: 1.0, address: "100 Coffee Ave", opening_time: "06:00", closing_time: "22:00")
        CoffeeShop.create!(name: "Far Shop", x_coordinate: 10.0, y_coordinate: 10.0, address: "101 Coffee Ave", opening_time: "07:00", closing_time: "23:00")

        post "/graphql",
            params: { query: query, variables: { x: 0.0, y: 0.0 } }.to_json,
            headers: { "Content-Type" => "application/json" }

        json = JSON.parse(response.body)
        shops = json["data"]["coffeeShops"]

        expect(response).to have_http_status(:ok)
        expect(shops.length).to eq(2)
        expect(shops.first["name"]).to eq("Near Shop")
        expect(shops.last["name"]).to eq("Far Shop")
        expect(shops.first["distance"]).to be < shops.last["distance"]
      end
      
       it "calculates distance correctly" do                                                                                                                                        
        CoffeeShop.create!(name: "Shop", x_coordinate: 3.0, y_coordinate: 4.0, address: "100 Coffee Ave", opening_time: "06:00", closing_time: "22:00")                            
                                                                                                                                                                                
        post "/graphql",                                                                                                                                                           
        params: { query: query, variables: { x: 0.0, y: 0.0 } }.to_json,                                                                                                         
        headers: { "Content-Type" => "application/json" }                                                                                                                        
    
        shops = JSON.parse(response.body)["data"]["coffeeShops"]                                                                                                                   
        expect(shops.first["distance"]).to eq(5.0)
       end
       
       it "returns shops ordered by ascending distance" do                                                                                                                          
        CoffeeShop.create!(name: "Far", x_coordinate: 10.0, y_coordinate: 10.0, address: "100 Coffee Ave", opening_time: "06:00", closing_time: "22:00")                           
        CoffeeShop.create!(name: "Near", x_coordinate: 1.0, y_coordinate: 1.0, address: "101 Coffee Ave", opening_time: "06:00", closing_time: "22:00")                            
        CoffeeShop.create!(name: "Mid", x_coordinate: 5.0, y_coordinate: 5.0, address: "102 Coffee Ave", opening_time: "06:00", closing_time: "22:00")                             
                                                                                                                                                                                
        post "/graphql",                                                                                                                                                           
        params: { query: query, variables: { x: 0.0, y: 0.0 } }.to_json,                                                                                                         
        headers: { "Content-Type" => "application/json" }                                                                                                                        
    
        shops = JSON.parse(response.body)["data"]["coffeeShops"]                                                                                                                   
        expect(shops.map { |s| s["name"] }).to eq(["Near", "Mid", "Far"])
       end  
    end
  end 