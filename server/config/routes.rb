Rails.application.routes.draw do
  # API routes
  namespace :api do
    namespace :v1 do
      # Auth routes
      devise_for :users, path: 'auth', path_names: {
        sign_in: 'login',
        sign_out: 'logout',
        registration: 'register'
      }, controllers: {
        sessions: 'api/v1/auth/sessions',
        registrations: 'api/v1/auth/registrations',
        passwords: 'api/v1/auth/passwords'
      }
      
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
          get :ranking
        end
      end
      
      # Profile routes
      resource :profile, only: [:show, :update]
      
      # Test routes (development only)
      post 'test/send_email', to: 'test#send_test_email' if Rails.env.development?
    end
  end
  
  # Health check
  get '/health', to: proc { [200, {}, ['OK']] }
  
  # Letter opener web (development only)
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
