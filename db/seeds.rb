if Rails.env.development?
  [
    ["Alma’s Oven", "Sunset, San Francisco", "Brown butter chocolate cookies", "regular", 1200, "cookies",
      "Six chewy chocolate cookies with crisp edges, a little sea salt, and plenty of brown butter."],
    ["The Little Batch", "Richmond, San Francisco", "Vanilla celebration cake", "organic", 3400, "pie",
      "A soft vanilla layer cake with a lightly sweet filling, baked with organic flour and eggs."],
    ["Jules at Home", "Oakland", "Raspberry French macarons", "glutenfree", 1600, "macarons",
      "Six almond macarons filled with raspberry buttercream. Contains almonds and dairy."],
    ["Morning Crumb", "Berkeley", "Maple crumble doughnuts", "vegan", 1800, "donuts",
      "Four baked doughnuts with a maple glaze and a crunchy oat topping."]
  ].reverse_each do |name, location, title, category, price, photo, description|
    email = "#{photo}@example.invalid"
    baker = User.find_or_create_by!(email: email) do |user|
      user.first_name = name
      user.location = location
      user.password = SecureRandom.hex(24)
      user.bio = "Sample baker profile for the BakR demo."
    end
    baker.products.find_or_create_by!(title: title) do |product|
      product.assign_attributes(category: category, price_cents: price, description: description,
        product_url: "/images/#{photo}.jpg")
    end
  end

  demo_password = "BakrDemo-Local26"
  User.find_or_create_by!(email: "buyer@bakr.example") do |buyer|
    buyer.assign_attributes(first_name: "Demo Buyer", location: "Amsterdam", password: demo_password)
  end

  baker = User.find_or_create_by!(email: "baker@bakr.example") do |user|
    user.assign_attributes(first_name: "Demo Baker", location: "Amsterdam", password: demo_password,
      contact_email: "orders@bakr.example", bio: "Try managing your listings on this demo profile.")
  end

  baker.products.find_or_create_by!(title: "Saturday cinnamon rolls") do |product|
    product.assign_attributes(category: "regular", price_cents: 1400,
      description: "Four soft cinnamon rolls finished with a vanilla glaze. Saturday pickup.")
  end
end
