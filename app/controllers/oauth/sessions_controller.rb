class OAuth::SessionsController < ApplicationController
  layout 'api_entreprise/application'

  helper_method :namespace

  def new
    if current_user
      redirect_to session[:user_return_to] || root_path
    else
      @client_name = oauth_client_name
    end
  end

  def namespace
    'api_entreprise'
  end

  private

  def oauth_client_name
    return_to = session[:user_return_to]
    return 'Application tierce' unless return_to

    uri = URI.parse(return_to)
    params = Rack::Utils.parse_query(uri.query)
    client_id = params['client_id']

    app = Doorkeeper::Application.find_by(uid: client_id)
    app&.name || 'Application tierce'
  rescue StandardError
    'Application tierce'
  end
end
