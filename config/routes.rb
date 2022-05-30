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

  root to: 'pages#home'
  root to: redirect('/login'), as: :dashboard_root, constraints: { subdomain: 'dashboard' }

  # Authentication
  get '/login', to: 'sessions#new'
  delete '/logout', to: 'sessions#destroy'
  post '/auth/api_gouv', as: :login_api_gouv
  match '/auth/api_gouv/callback', to: 'sessions#create', via: [:get, :post]
  get '/auth/failure', to: 'sessions#failure'

  get '/profile', to: 'users#profile', as: :user_profile
  get '/profile/tokens', to: 'jwt_api_entreprise#index', as: :user_tokens

  scope :profile do
    resources :attestations, only: %i[index new] do
      collection do
        post :search
      end
    end
  end

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

  resources :faq, only: %i[index]

  get '/developers/openapi', to: 'pages#redoc'

  get '/home', to: 'pages#home'
  get '/developers', to: 'pages#developers'
  get '/mentions', to: 'pages#mentions'
  get '/cgu', to: 'pages#cgu'
  get '/current_status', to: 'pages#current_status'

  get '/v3/openapi.yaml', to: ->(env) { [200, {}, [OpenAPIDefinition.instance.open_api_definition_content]] }, as: :openapi_definition
end
