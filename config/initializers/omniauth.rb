client_id = ENV["GOOGLE_CLIENT_ID"].presence
client_secret = ENV["GOOGLE_CLIENT_SECRET"].presence

if Rails.env.test?
  client_id = "test-client-id"
  client_secret = "test-client-secret"
end

Rails.application.config.x.google_sign_in = client_id.present? && client_secret.present?

if Rails.application.config.x.google_sign_in
  origin = ENV["GOOGLE_OAUTH_ORIGIN"].presence
  if Rails.env.production? && origin.nil?
    raise "Set GOOGLE_OAUTH_ORIGIN to the public HTTPS origin to enable Google sign-in"
  end

  OmniAuth.config.full_host = (origin || "http://localhost:3000").delete_suffix("/")
  OmniAuth.config.failure_raise_out_environments = []

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, client_id, client_secret, scope: "openid email profile", access_type: "online", pkce: true,
      overridable_authorize_options: []
  end
end
