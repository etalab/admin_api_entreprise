Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/api/admin/sidekiq'

  scope 'api/admin' do
    # Authentication
    get  '/oauth_api_gouv/login'      => 'oauth_api_gouv#login'
    post '/users/login'               => 'doorkeeper/tokens#create'
    post '/users/password_renewal'    => 'users#password_renewal'
    post '/users/password_reset'      => 'users#password_reset'

    # Incidents
    get  '/incidents'     => 'incidents#index'
    post '/incidents'     => 'incidents#create'
    put  '/incidents/:id' => 'incidents#update'

    #roles
    get  '/roles' => 'roles#index'
    post '/roles' => 'roles#create'

    # users
    get    '/users'                            => 'users#index'
    post   '/users'                            => 'users#create'
    get    '/users/:id'                        => 'users#show'
    patch  '/users/:id'                        => 'users#update'
    delete '/users/:id'                        => 'users#destroy'
    post   '/users/:id/transfer_ownership'     => 'users#transfer_ownership'

    # jwt_api_entreprise
    get   '/jwt_api_entreprise'                       => 'jwt_api_entreprise#index'
    post  '/users/:user_id/jwt_api_entreprise'        => 'jwt_api_entreprise#create'
    patch '/jwt_api_entreprise/:id'                   => 'jwt_api_entreprise#update'
    post  '/jwt_api_entreprise/:id/create_magic_link' => 'jwt_api_entreprise#create_magic_link'
    get   '/jwt_api_entreprise/show_magic_link'       => 'jwt_api_entreprise#show_magic_link'
  end
end
