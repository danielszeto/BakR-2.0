require "test_helper"

class GoogleSignInTest < ActionDispatch::IntegrationTest
  REQUEST_PATH = "/auth/google_oauth2"
  CALLBACK_PATH = "/auth/google_oauth2/callback"
  PASSWORD = "Fresh-bakes-2026"

  setup do
    @previous_test_mode = OmniAuth.config.test_mode
    host! URI(OmniAuth.config.full_host).authority
    OmniAuth.config.test_mode = true
    mock_google
  end

  teardown do
    OmniAuth.config.test_mode = @previous_test_mode
    OmniAuth.config.mock_auth.delete(:google_oauth2)
  end

  test "sign-in and signup pages offer a POST to Google" do
    get sign_in_path, params: { return_to: "/products/23" }
    assert_select "form[method=post][action=?]", REQUEST_PATH do
      assert_select "button", "Continue with Google"
      assert_select "input[name=return_to][value='/products/23']"
    end

    get new_user_path
    assert_select "form[method=post][action=?] button", REQUEST_PATH, "Sign up with Google"
  end

  test "a verified Google account is created and can return to the listing" do
    assert_difference "User.count", 1 do
      start_google(return_to: "/products/23")
    end
    user = User.find_by!(google_uid: "google-person-123")
    assert_equal "maya@example.com", user.email
    assert_equal "Maya", user.first_name
    assert_nil user.location
    assert_redirected_to "/products/23"

    get new_product_path
    assert_redirected_to edit_user_path(user)

    patch user_path(user), params: { user: { location: "Amsterdam" } }
    assert_redirected_to user_path(user)
    get new_product_path
    assert_response :success

    delete logout_path
    assert_no_difference "User.count" do
      mock_google(email: "new-address@example.com")
      start_google
    end
    assert_redirected_to user_path(user)
  end

  test "Google cannot automatically take over an existing password account" do
    user = password_user

    assert_no_difference "User.count" do
      start_google
    end
    assert_redirected_to sign_in_path
    assert_nil user.reload.google_uid
    get new_product_path
    assert_redirected_to sign_in_path
  end

  test "a signed-in user can explicitly connect their matching Google account" do
    user = password_user
    sign_in(user)
    follow_redirect!
    assert_select "form[action=?] button", REQUEST_PATH, "Connect Google"

    start_google
    assert_redirected_to user_path(user)
    assert_equal "google-person-123", user.reload.google_uid

    delete logout_path
    start_google
    assert_redirected_to user_path(user)
  end

  test "a signed-in user cannot connect a Google account with a different email" do
    user = password_user
    sign_in(user)
    mock_google(email: "other@example.com")
    start_google
    assert_redirected_to user_path(user)
    assert_nil user.reload.google_uid
  end

  test "unverified Google identities and canceled requests return to sign-in" do
    assert_no_difference "User.count" do
      mock_google(verified: false)
      start_google
      assert_redirected_to sign_in_path

      OmniAuth.config.mock_auth[:google_oauth2] = :access_denied
      start_google
      follow_redirect!
      assert_redirected_to sign_in_path
    end
    get new_product_path
    assert_redirected_to sign_in_path
  end

  test "an unsigned Google callback is rejected and a real request uses PKCE and state" do
    OmniAuth.config.test_mode = false
    get CALLBACK_PATH
    assert_match %r{/auth/failure\?}, response.location

    post REQUEST_PATH
    assert_response :redirect
    auth_url = URI.parse(response.location)
    authorization = URI.decode_www_form(auth_url.query).to_h
    assert_equal "accounts.google.com", auth_url.host
    assert_equal "#{OmniAuth.config.full_host}#{CALLBACK_PATH}", authorization["redirect_uri"]
    assert_equal "openid email profile", authorization["scope"]
    assert_equal "online", authorization["access_type"]
    assert_equal "S256", authorization["code_challenge_method"]
    assert authorization["state"].present?
  end

  private

  def mock_google(email: "MAYA@example.com", verified: true)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2", uid: "google-person-123",
      info: { email: email, first_name: "Maya" },
      extra: { raw_info: { email_verified: verified } }
    )
  end

  def password_user
    User.create!(email: "maya@example.com", first_name: "Maya", location: "Amsterdam", password: PASSWORD)
  end

  def sign_in(user)
    post sessions_path, params: { user: { email: user.email, password: PASSWORD } }
    assert_redirected_to user_path(user)
  end

  def start_google(params = {})
    post REQUEST_PATH, params: params
    assert_response :redirect
    follow_redirect!
  end
end
