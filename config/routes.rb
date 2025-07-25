Rails.application.routes.draw do
  GoodJob::Engine.middleware.use(Rack::Auth::Basic) do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(Rails.application.credentials.workers_ui_username)) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(Rails.application.credentials.workers_ui_password))
  end
  mount GoodJob::Engine => '/workers'

  get '/admin', to: redirect('/admin/users')

  namespace :admin do
    resources :users, only: %i[index edit update] do
      post :impersonate, on: :member
      post :stop_impersonating, on: :collection
    end
    resources :editors, only: %i[index edit update]
    resources :provider_dashboards, only: %i[index show], path: 'providers'
    resources :audit_notifications, only: %i[index new create]
  end

  get '/editeur', to: redirect('/editeur/habilitations'), as: :editor

  namespace :editor, path: 'editeur' do
    resources :authorization_requests, only: %i[index], path: 'habilitations'
  end

  get '/fournisseur', to: 'provider/dashboard#index', as: :provider

  scope path: 'fournisseur/:provider_uid', as: :provider do
    get '/tableau-de-bord', to: 'provider/dashboard#show', as: :dashboard
  end

  namespace :api do
    resources :frontal, only: :index
  end

  draw(:api_entreprise)
  draw(:api_particulier)
end
