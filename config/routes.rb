Rails.application.routes.draw do
  # Devise routes for Admins
  devise_for :admins, skip: [:registrations]

  # Devise routes for Users
  devise_for :users

  # Posts and nested Lessons routes
  resources :posts do
    resources :lessons do
      post 'unlock_course', on: :member
    end
  end

  # Admin-specific routes
  namespace :admin do
    resources :posts do
      resources :lessons
    end

    # Admin dashboard
    get "/", to: "admin#index", as: :admin_dashboard
  end

  # Chatbots routes
  resource :chatbots, only: [:create]
  get "chatbot", to: "chatbots#index"
  post "chatbot", to: "chatbots#create"

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Authenticated root paths
  authenticated :admin do
    root to: "admin#index", as: :admin_root
  end

  authenticated :user do
    root to: "posts#index", as: :authenticated_root
  end

  # Default unauthenticated root path
  root to: "pages#landing"

  # Fallback route for lobby (if needed for authenticated users)
  get "lobby", to: "posts#index"
end
