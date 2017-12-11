Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope 'api/admin' do
    resources :roles, only: [:index, :create]
    resources :users, only: [:index, :create, :show, :destroy] do
      resources :tokens, only: [:create]
    end

    # User account lifecycle routes
    post 'users/confirm/:confirmation_token', to: 'users#confirm'
  end
end
