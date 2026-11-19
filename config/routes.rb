Rails.application.routes.draw do
  root "products#index"
  resources :products
  resources :users, only: %i[new create show edit update]
  get "/sign_in", to: "sessions#new", as: :sign_in
  post "/sessions", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout
  get "/auth/google_oauth2/callback", to: "sessions#google"
  get "/auth/failure", to: "sessions#google_failure"
  get "/up", to: "rails/health#show"
end
