require_relative "boot"
require "rails"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module Bakr
  class Application < Rails::Application
    config.load_defaults 8.1
    config.time_zone = "UTC"
    config.session_store :cookie_store, key: "_bakr_session", same_site: :lax, httponly: true
    config.filter_parameters += %i[password password_confirmation email contact_email code state code_verifier]
    config.action_dispatch.default_headers["Referrer-Policy"] = "no-referrer"
  end
end
