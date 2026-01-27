constraints(APIParticulierDomainConstraint.new) do
  namespace :api do
    post '/datapass/api_particulier/webhook' => 'datapass_webhooks#api_particulier'
    post '/datapass/v2/api_particulier/webhook' => 'datapass_webhooks_v2#api_particulier'
  end

  post '/auth/api_gouv_particulier', as: :login_api_gouv_particulier
  post '/auth/proconnect_api_particulier', as: :login_proconnect_particulier

  scope module: :api_particulier do
    get '/auth/:provider/callback', to: 'sessions#create_from_oauth', constraints: { provider: /proconnect_api_entreprise|proconnect_api_particulier/ }
    get '/auth/failure', to: 'sessions#failure'
    get '/robots.txt', to: ->(env) { [200, {}, [File.read('config/seo/robots.txt') % { app: 'particulier' }]] }
    get '/status/apis', to: 'pages#current_status', as: :api_particulier_current_status
  end

  namespace :api_particulier, path: '' do
    get '/', to: 'pages#home'

    get '/stats', to: 'stats#index'

    get '/catalogue', as: :endpoints, to: 'endpoints#index'
    get '/catalogue/*uid/exemple', as: :endpoint_example, to: 'endpoints#example'
    get '/catalogue/*uid', as: :endpoint, to: 'endpoints#show'

    get '/open-api.yml', to: ->(env) { [200, {}, [APIParticulier::OpenAPIDefinition.instance.open_api_definition_content]] }, as: :openapi_definition
    get '/open-api-v2.yml', to: ->(env) { [200, {}, [APIParticulier::OpenAPIDefinition.instance.open_api_v2_definition_content]] }, as: :openapi_v2_definition
    get '/open-api-v3.yml', to: ->(env) { [200, {}, [APIParticulier::OpenAPIDefinition.instance.open_api_v3_definition_content]] }, as: :openapi_v3_definition
    get '/open-api-without-deprecated-paths.yml', to: ->(env) { [200, {}, [APIParticulier::OpenAPIDefinition.instance.open_api_without_deprecated_paths_definition_content]] }, as: :openapi_without_deprecated_definition

    get '/faq', to: 'faq#index', as: :faq_index
    get '/developpeurs', to: 'documentation#developers', as: :developers
    get '/developpeurs/openapi', to: 'pages#redoc', as: :developers_openapi
    get '/developpeurs/openapi-v2', to: 'pages#redoc_v2', as: :developers_openapi_v2
    get '/developpeurs/openapi-v3', to: 'pages#redoc_v3', as: :developers_openapi_v3
    get '/cas_usages', to: 'cas_usages#index'
    get '/cas_usages/:uid', to: 'cas_usages#show', as: :cas_usage

    get '/compte/se-connecter', to: 'sessions#new', as: :login
    get '/compte/se-connecter/lien-magique', to: 'sessions#create_from_magic_link', as: :login_magic_link
    get '/compte/dev-login', to: 'sessions#dev_login', as: :dev_login
    get '/compte/deconnexion', to: 'sessions#destroy', as: :logout
    get '/compte/apres-deconnexion', to: 'sessions#after_logout', as: :after_logout

    get '/compte', to: 'users#profile', as: :user_profile

    get '/compte/demandes', to: 'authorization_requests#index', as: :authorization_requests
    get '/compte/demandes/:id', to: 'authorization_requests#show', as: :authorization_request

    get '/compte/jetons/:id/prolonger', to: 'tokens#prolong', as: :token_prolong
    get '/compte/jetons/:id/partager', to: 'transfer_tokens#new', as: :token_transfer
    get '/compte/jetons/:id', to: 'tokens#show', as: :token
    get '/compte/jetons/:id/demande-prolongation', to: 'tokens#ask_for_prolongation', as: :token_ask_for_prolongation
    get '/compte/jetons/:id/stats', to: 'tokens#stats', as: :token_stats
    get '/compte/jetons/:id/renew', to: 'tokens#renew', as: :token_renew


    get '/compte/jetons/:token_id/demarche_prolongation/finished', to: 'prolong_token_wizard#finished', as: :token_prolong_finished
    get '/compte/jetons/:token_id/demarche_prolongation/:id', to: 'prolong_token_wizard#show', as: :token_prolong_build
    get '/compte/jetons/:token_id/demarche_prolongation', to: 'prolong_token_wizard#start', as: :token_prolong_start
    patch '/compte/jetons/:token_id/demarche_prolongation/:id', to: 'prolong_token_wizard#update'
    put '/compte/jetons/:token_id/demarche_prolongation/:id', to: 'prolong_token_wizard#update'

    post 'public/magic_link/create', to: 'public_token_magic_links#create'
    post '/compte/jetons/:id/partager', to: 'transfer_tokens#create', as: :token_create_magic_link

    get 'public/jetons/:access_token', to: 'public_token_magic_links#show', as: :token_show_magic_link

    get '/blog/:id', to: 'blog_posts#show', as: :blog_post

    get '/infolettre', to: 'pages#newsletter', as: :newsletter
    get '/mentions-legales', to: 'pages#mentions', as: :mentions
    get '/cgu', to: 'pages#cgu', as: :cgu
    get '/donnees_personnelles', to: 'pages#donnees_personnelles', as: :donnees_personnelles
    get '/accessibilite', to: 'pages#accessibility', as: :accessibilite

    get '/datapass', to: 'reporters#index', as: :dashboard_reporter
  end
end
