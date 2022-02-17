Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/api/admin/sidekiq'

  namespace :api do
    scope '/admin' do
      # datapass webhook
      post '/datapass/webhook' => 'datapass_webhooks#create'
    end
  end

  root to: redirect('/login')

  # Authentication
  get '/login', to: 'sessions#new'
  delete '/logout', to: 'sessions#destroy'
  post '/auth/api_gouv', as: :login_api_gouv
  match '/auth/api_gouv/callback', to: 'sessions#create', via: [:get, :post]
  get '/auth/failure', to: 'sessions#failure'

  get '/profile', to: 'users#profile', as: :user_profile
  get '/profile/tokens', to: 'jwt_api_entreprise#index', as: :user_tokens
  get '/profile/attestations', to: 'attestations#index', as: :user_attestations
  get '/profile/attestations/new', to: 'attestations#new'
  post 'tokens/:id/create_magic_link', to: 'restricted_token_magic_links#create', as: :token_create_magic_link
  get 'tokens/:id/stats', to: 'jwt_api_entreprise#stats', as: :token_stats
  get 'tokens/:id', to: 'jwt_api_entreprise#show', as: :token
  get 'tokens/:id/contacts', to: 'contacts#index', as: :token_contacts
  get '/public/tokens/:token', to: 'public_token_magic_links#show', as: :token_show_magic_link

  resources :users, only: [] do
    resources :transfer_account, only: [:new, :create], controller: :transfer_user_account
  end

  resources :authorization_requests, only: :index

  resources :endpoints, only: %i[index]
  get 'endpoints/*uid/example', as: :endpoint_example, to: 'endpoints#example'
  get 'endpoints/*uid', as: :endpoint, to: 'endpoints#show'

  get '/developers/openapi', to: 'pages#redoc'

  namespace :admin do
    get '/private_metrics' => 'private_metrics#index'

    resources :users, only: %i[index show update]
    resources :tokens, only: %i[index show] do
      member do
        patch :archive
        patch :blacklist
      end
    end

    resources :contacts, only: %i[edit update]
  end

  get '/mentions', to: 'pages#mentions'
  get '/cgu', to: 'pages#cgu'
  get '/current_status', to: 'pages#current_status'

  get '/v3/openapi.yaml', to: ->(env) { [200, {}, [OpenAPIDefinition.instance.open_api_definition_content]] }, as: :openapi_definition
end
