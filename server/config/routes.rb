Rails.application.routes.draw do
  # API routes
  namespace :api do
    namespace :v1 do
      # Auth routes
      post '/auth/register', to: 'auth#register'
      post '/auth/login', to: 'auth#login'
      delete '/auth/logout', to: 'auth#logout'
      
      # Posts routes
      resources :posts, only: [:index, :show, :create, :update, :destroy] do
        # Sympathies routes
        resources :sympathies, only: [:create, :destroy]
        # Replies routes  
        resources :replies, only: [:index, :create] do
          member do
            patch :select_best
          end
        end
      end
      
      # User routes
      resources :users, only: [:show] do
        member do
          get :points_history
        end
        collection do
          get :ranking
        end
      end
      
      # Profile routes
      resource :profile, only: [:show, :update]
    end
  end
  
  # Health check
  get '/health', to: proc { [200, {}, ['OK']] }
end
