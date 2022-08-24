constraints(APIParticulierDomainConstraint.new) do
  namespace :api_particulier, path: '' do
    get '/', to: 'pages#home'

    get '/compte/se-connecter', to: 'sessions#new', as: :login
    delete '/compte/deconnexion', to: 'sessions#destroy', as: :logout

    match '/auth/api_gouv/callback', to: 'sessions#create', via: [:get, :post]
    get '/auth/failure', to: 'sessions#failure'

    get '/compte', to: 'users#profile', as: :user_profile
  end
end
