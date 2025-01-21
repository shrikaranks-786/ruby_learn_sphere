Rails.application.routes.draw do
  devise_for :admins
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  
  devise_scope :user do
    post '/users/generate_otp', to: 'users/otp#generate_otp'
    post '/users/verify_otp', to: 'users/otp#verify_otp'
  end

  resources :posts do
    resources :lessons do
      post 'unlock_course', on: :member
      post :chatbot_ask, on: :member
    end
  end

  resources :posts do
    resources :ratings, only: [:create]
    resources :unlocks, only: [:create]
  end

  namespace :admin do
    resources :posts do
      resources :lessons
    end

    resources :users

    # Admin dashboard accessible only under /admin
    get "/", to: "admin#index", as: :admin_dashboard
  end

  # Chatbots routes
  resource :chatbots, only: [:create]
  get "chatbot", to: "chatbots#index"
  post "chatbot", to: "chatbots#create"

  resources :lessons do
    member do
      post :chatbot_ask
    end
  end

  resources :posts do
    resources :lessons do
      resources :comments, only: :create
    end
  end
  

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Ensure no dashboard for admin at the root path
  authenticated :admin do
    root to: "pages#landing", as: :admin_authenticated_root # Renamed this route
  end

  authenticated :user do
    root to: "posts#index", as: :authenticated_root
  end

  # Default unauthenticated root path
  root to: "pages#landing"

  # Fallback route for lobby (if needed for authenticated users)
  get "lobby", to: "posts#index"
end
