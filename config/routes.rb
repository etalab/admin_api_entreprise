Rails.application.routes.draw do
  GoodJob::Engine.middleware.use(Rack::Auth::Basic) do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(Rails.application.credentials.workers_ui_username)) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(Rails.application.credentials.workers_ui_password))
  end
  mount GoodJob::Engine => '/workers'

  get '/admin', to: redirect('/admin/users')

  get '/what', to: ->(env) { [200, { 'Content-Type' => 'text/plain' }, ['ever']] }

  namespace :admin do
    resources :users, only: %i[index edit update] do
      post :impersonate, on: :member
      post :stop_impersonating, on: :collection
    end
    resources :editors, only: %i[index edit update]
  end

  get '/editeur', to: redirect('/editeur/habilitations'), as: :editor

  namespace :editor, path: 'editeur' do
    resources :authorization_requests, only: %i[index], path: 'habilitations'
  end

  namespace :api do
    resources :frontal, only: :index
  end

  draw(:api_entreprise)
  draw(:api_particulier)
end
