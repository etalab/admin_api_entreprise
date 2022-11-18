constraints(APIParticulierDomainConstraint.new) do
  namespace :api_particulier, path: '' do
    get '/', to: redirect('https://api.gouv.fr/les-api/api-particulier', status: 302)

    get '/compte/se-connecter', to: 'sessions#new', as: :login
    delete '/compte/deconnexion', to: 'sessions#destroy', as: :logout

    match '/auth/api_gouv/callback', to: 'sessions#create', via: [:get, :post]
    get '/auth/failure', to: 'sessions#failure'

    get '/compte', to: 'users#profile', as: :user_profile

    get 'public/jetons/:access_token', to: 'public_token_magic_links#show', as: :token_show_magic_link
  end
end
