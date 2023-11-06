constraints(APIEntrepriseDomainConstraint.new) do
  namespace :api do
    post '/datapass/api_entreprise/webhook' => 'datapass_webhooks#api_entreprise'
    post '/datapass/api_particulier/webhook' => 'datapass_webhooks#api_particulier'
  end

  post '/auth/api_gouv_entreprise', as: :login_api_gouv_entreprise

  scope module: :api_entreprise do
    root to: redirect('/compte/se-connecter'), as: :dashboard_root, constraints: { subdomain: 'dashboard.entreprise.api' }
    root to: 'pages#home'

    get '/stats', to: 'stats#index'

    get '/auth/api_gouv_entreprise/callback', to: 'sessions#create_from_oauth'
    get '/auth/failure', to: 'sessions#failure'

    get '/compte/se-connecter', to: 'sessions#new', as: :login
    get '/compte/se-connecter/lien-magique', to: 'sessions#create_from_magic_link', as: :login_magic_link
    get '/compte/deconnexion', to: 'sessions#destroy', as: :logout
    get '/compte/apres-deconnexion', to: 'sessions#after_logout', as: :after_logout

    get '/compte', to: 'users#profile', as: :user_profile

    get '/compte/demandes', to: 'authorization_requests#index', as: :authorization_requests
    get '/compte/demandes/:id', to: 'authorization_requests#show', as: :authorization_requests_show

    get '/compte/telecharcher-documents', to: 'attestations#index', as: :attestations
    post '/compte/telecharcher-documents/rechercher-siret', to: 'attestations#search', as: :search_attestations

    get '/compte/jetons', to: 'tokens#index', as: :user_tokens
    post '/compte/jetons/:id/partager', to: 'restricted_token_magic_links#create', as: :token_create_magic_link
    get '/compte/jetons/:id/stats', to: 'tokens#stats', as: :token_stats
    get '/compte/jetons/:id', to: 'tokens#show', as: :token
    get '/compte/jetons/:id/renew', to: 'tokens#renew', as: :token_renew
    get '/compte/jetons/:id/prolonger', to: 'tokens#prolong', as: :token_prolong
    get '/compte/jetons/:id/demande-prolongation', to: 'tokens#ask_for_prolongation', as: :token_ask_for_prolongation
    get '/compte/jetons/:id/contacts', to: 'contacts#index', as: :token_contacts

    post 'public/magic_link/create', to: 'public_token_magic_links#create'
    get 'public/jetons/:access_token', to: 'public_token_magic_links#show', as: :token_show_magic_link

    get '/compte/transferer', to: 'transfer_user_account#new', as: :transfer_account
    post '/compte/transferer', to: 'transfer_user_account#create'

    get '/catalogue', as: :endpoints, to: 'endpoints#index'
    get '/catalogue/*uid/exemple', as: :endpoint_example, to: 'endpoints#example'
    get '/catalogue/*uid', as: :endpoint, to: 'endpoints#show'

    get '/faq', to: 'faq#index', as: :faq_index
    get '/developpeurs', to: 'documentation#developers', as: :developers
    get '/developpeurs/guide-migration', to: 'documentation#guide_migration', as: :guide_migration
    get '/developpeurs/openapi', to: 'pages#redoc', as: :developers_openapi
    get '/cas_usages', to: 'cas_usages#index'
    get '/cas_usages/:uid', to: 'cas_usages#show', as: :cas_usage

    get '/blog/:id', to: 'blog_posts#show', as: :blog_post

    get '/apis/status', to: 'pages#current_status', as: :current_status

    get '/open-api.yml', to: ->(env) { [200, {}, [APIEntreprise::OpenAPIDefinition.instance.open_api_definition_content]] }, as: :openapi_definition
    get '/open-api-without-deprecated-paths.yml', to: ->(env) { [200, {}, [APIEntreprise::OpenAPIDefinition.instance.open_api_without_deprecated_paths_definition_content]] }, as: :openapi_without_deprecated_definition
    get '/robots.txt', to: ->(env) { [200, {}, URI.open('config/seo/api-entreprise/robots.txt')] }

    get '/infolettre', to: 'pages#newsletter', as: :newsletter
    get '/mentions-legales', to: 'pages#mentions', as: :mentions
    get '/cgu', to: 'pages#cgu', as: :cgu
    get '/accessibilite', to: 'pages#accessibility', as: :accessibilite
  end
end
