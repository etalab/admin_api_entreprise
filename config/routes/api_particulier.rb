constraints(APIParticulierDomainConstraint.new) do
  post '/auth/api_gouv_particulier', as: :login_api_gouv_particulier

  scope module: :api_particulier do
    get '/auth/api_gouv_particulier/callback', to: 'sessions#create_from_oauth'
    get '/robots.txt', to: ->(env) { [200, {}, URI.open('config/seo/api-particulier/robots.txt')] }
  end

  namespace :api_particulier, path: '' do
    get '/', to: 'pages#home'

    get '/stats', to: 'stats#index'

    get '/open-api.yml', to: ->(env) { [200, {}, [APIParticulier::OpenAPIDefinition.instance.open_api_definition_content]] }, as: :openapi_definition
    get '/developpeurs/openapi', to: 'pages#redoc', as: :developers_openapi

    get '/compte/se-connecter', to: 'sessions#new', as: :login
    get '/compte/se-connecter/lien-magique', to: 'sessions#create_from_magic_link', as: :login_magic_link
    delete '/compte/deconnexion', to: 'sessions#destroy', as: :logout

    get '/compte', to: 'users#profile', as: :user_profile

    post 'public/magic_link/create', to: 'public_token_magic_links#create'
    get 'public/jetons/:access_token', to: 'public_token_magic_links#show', as: :token_show_magic_link
  end
end
