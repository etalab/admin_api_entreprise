Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/api/admin/sidekiq'

  scope 'api/admin' do
    resources :incidents, only: [:index, :create, :update]
    resources :roles, only: [:index, :create]
    resources :jwt_api_entreprise, only: [:update]
    resources :users, only: [:index, :create, :show, :update, :destroy] do
      resources :jwt_api_entreprise, only: [:create]

      # User account related routes
      collection do
        post :confirm
        post :password_renewal
        post :password_reset
        post :login, to: 'doorkeeper/tokens#create'
      end
    end
  end
end
