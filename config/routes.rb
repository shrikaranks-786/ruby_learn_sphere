Rails.application.routes.draw do
  devise_for :admins, skip: [ :registrations ]
  devise_for :users

  resources :posts do
    resources :lessons
  end

  authenticated :admin_user do
    root to: "admin#index", as: :admin_root
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "admin" => "admin#index"

  # Landing page for unauthenticated users
  root to: "pages#landing"

  # Lobby (posts#index) for authenticated users
  get "lobby", to: "posts#index"
end
