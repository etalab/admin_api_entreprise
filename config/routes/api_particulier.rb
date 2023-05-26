constraints(APIParticulierDomainConstraint.new) do
  post '/auth/api_gouv_particulier', as: :login_api_gouv_particulier

  scope module: :api_particulier do
    get '/auth/api_gouv_particulier/callback', to: 'sessions#create_from_oauth'
    get '/robots.txt', to: ->(env) { [200, {}, URI.open('config/seo/api-particulier/robots.txt')] }
  end

  namespace :api_particulier, path: '' do
    get '/', to: 'pages#home'

    get '/stats', to: 'stats#index'

    get '/catalogue', as: :endpoints, to: 'endpoints#index'
    get '/catalogue/*uid/exemple', as: :endpoint_example, to: 'endpoints#example'
    get '/catalogue/*uid', as: :endpoint, to: 'endpoints#show'

    get '/open-api.yml', to: ->(env) { [200, {}, [APIParticulier::OpenAPIDefinition.instance.open_api_definition_content]] }, as: :openapi_definition

    get '/faq', to: 'faq#index', as: :faq_index
    get '/developpeurs', to: 'documentation#developers', as: :developers
    get '/developpeurs/openapi', to: 'pages#redoc', as: :developers_openapi

    get '/compte/se-connecter', to: 'sessions#new', as: :login
    get '/compte/se-connecter/lien-magique', to: 'sessions#create_from_magic_link', as: :login_magic_link
    delete '/compte/deconnexion', to: 'sessions#destroy', as: :logout

    get '/compte', to: 'users#profile', as: :user_profile

    post 'public/magic_link/create', to: 'public_token_magic_links#create'
    get 'public/jetons/:access_token', to: 'public_token_magic_links#show', as: :token_show_magic_link

    get '/mentions-legales', to: 'pages#mentions', as: :mentions
    get '/cgu', to: 'pages#cgu', as: :cgu
    get '/accessibilite', to: 'pages#accessibility', as: :accessibilite
  end
end
