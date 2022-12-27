Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'sidekiq/cron/web'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq_ui_username)) &
        ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq_ui_password))
  end
  mount Sidekiq::Web => '/sidekiq'

  get '/auth/failure', to: 'sessions#failure'

  draw(:api_entreprise)
  draw(:api_particulier)
end
