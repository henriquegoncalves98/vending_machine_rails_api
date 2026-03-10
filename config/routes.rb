Rails.application.routes.draw do
  # Defines the root path route ("/")
  root "products#index"

  resources :products, only: %i[index show create update destroy] do
    post :purchase, on: :member
    post :refill, on: :collection
  end

  namespace :coins do
    post :refill
  end
end
