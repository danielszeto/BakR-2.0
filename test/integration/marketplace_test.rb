require "test_helper"

class MarketplaceTest < ActionDispatch::IntegrationTest
  PASSWORD = "Fresh-bakes-2026"

  test "signup, listing management, and logout" do
    get new_user_path
    assert_response :success
    assert_select "form[action=?]", users_path

    assert_difference "User.count", 1 do
      post users_path, params: {
        user: { first_name: "Alma", location: "San Francisco", email: " ALMA@example.com ",
                password: PASSWORD, password_confirmation: PASSWORD }
      }
    end
    baker = User.find_by!(email: "alma@example.com")
    assert_redirected_to user_path(baker)

    get new_product_path
    assert_response :success
    assert_select "form[action=?]", products_path

    assert_difference "baker.products.count", 1 do
      post products_path, params: { product: listing_params }
    end
    product = baker.products.last
    assert_redirected_to product_path(product)
    follow_redirect!
    assert_select "h1", "Oat cookies"
    assert_select ".detail-price", "$12.50"
    assert_select "a[href=?]", edit_product_path(product)

    get edit_product_path(product)
    assert_response :success
    patch product_path(product), params: { product: { title: "Maple cookies", available: "0" } }
    assert_redirected_to product_path(product)
    assert_equal "Maple cookies", product.reload.title
    assert_not product.available?

    assert_difference "baker.products.count", -1 do
      delete product_path(product)
    end
    assert_redirected_to user_path(baker)

    delete logout_path
    assert_redirected_to root_path
    get new_product_path
    assert_redirected_to sign_in_path
  end

  test "marketplace shows available listings and supports the original dietary filters" do
    baker = make_user("Baker")
    vegan = baker.products.create!(listing_params)
    classic = baker.products.create!(listing_params.merge(title: "Classic buns", category: "regular"))
    paused = baker.products.create!(listing_params.merge(title: "Paused loaf", available: false))

    get root_path
    assert_response :success
    assert_select "h1", /Baked close/
    assert_select "link[rel=stylesheet][href*='bakr']"
    assert_select "a[href=?]", product_path(vegan)
    assert_select "a[href=?]", product_path(classic)
    assert_select "a[href=?]", product_path(paused), count: 0

    get products_path, params: { type: "VEGAN" }
    assert_response :success
    assert_select "a[aria-current=page]", "Vegan"
    assert_select "a[href=?]", product_path(vegan)
    assert_select "a[href=?]", product_path(classic), count: 0

    get products_path, params: { type: "organic" }
    assert_response :success
    assert_select "h3", "No listings in this category"
  end

  test "buyers can sign in to contact a baker without seeing the login email" do
    baker = make_user("Baker", contact_email: "orders@example.com")
    buyer = make_user("Buyer")
    product = baker.products.create!(listing_params)

    get product_path(product)
    assert_response :success
    assert_select "a[href^='mailto:']", count: 0
    assert_select "a", "Sign in to contact baker"

    get sign_in_path, params: { return_to: product_path(product) }
    assert_select "input[name=return_to][value=?]", product_path(product)
    post sessions_path, params: { user: { email: "BUYER@example.com", password: PASSWORD }, return_to: product_path(product) }
    assert_redirected_to product_path(product)
    follow_redirect!
    assert_select "a[href='mailto:orders@example.com']", "Email baker"
    assert_not_includes response.body, baker.email

    product.update!(available: false)
    get product_path(product)
    assert_response :success
    assert_select "a[href^='mailto:']", count: 0
  end

  test "another account cannot change listings or baker profiles" do
    baker = make_user("Baker")
    product = baker.products.create!(listing_params)
    sign_in(make_user("Buyer"))

    get edit_product_path(product)
    assert_response :forbidden
    patch product_path(product), params: { product: { title: "Changed title" } }
    assert_response :forbidden
    delete product_path(product)
    assert_response :forbidden
    assert_equal "Oat cookies", product.reload.title

    patch user_path(baker), params: { user: { first_name: "Someone else" } }
    assert_response :forbidden
    assert_equal "Baker", baker.reload.first_name
  end

  test "invalid forms preserve the listing and report errors" do
    baker = make_user("Baker")
    sign_in(baker)

    assert_no_difference "Product.count" do
      post products_path, params: {
        product: listing_params.merge(price: "1.001", product_url: "http://example.com/photo.jpg")
      }
    end
    assert_response 422
    assert_select "[role=alert] li", /Price/
    assert_select "[role=alert] li", /valid HTTPS link/
  end

  private

  def listing_params
    { title: "Oat cookies", category: "vegan", description: "Six fresh cookies.", price: "12.50" }
  end

  def make_user(name, contact_email: nil)
    User.create!(first_name: name, location: "San Francisco", email: "#{name.downcase}@example.com",
      password: PASSWORD, contact_email: contact_email)
  end

  def sign_in(user)
    post sessions_path, params: { user: { email: user.email, password: PASSWORD } }
    assert_redirected_to user_path(user)
  end
end
