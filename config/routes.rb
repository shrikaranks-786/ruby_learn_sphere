Rails.application.routes.draw do
  devise_for :admins, skip: [:registrations]
  devise_for :users

  resources :posts do
    resources :lessons
  end

  resources :posts do
    resources :lessons do
      post 'unlock_course', on: :member
    end
  end

  # Ensure /admin route points to the correct controller/action
  authenticated :admin do
    root to: "admin#index", as: :admin_root
    get "/admin", to: "admin#index", as: :admin_dashboard
  end

  namespace :admin do
      resources :posts
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # Landing page for unauthenticated users
  root to: "pages#landing"

  # Lobby (posts#index) for authenticated users
  get "lobby", to: "posts#index"
end
