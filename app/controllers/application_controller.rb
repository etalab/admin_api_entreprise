class ApplicationController < ActionController::Base
  before_action :require_login

  def current_user
    @current_user ||= session[:current_user_id] &&
      User.find(session[:current_user_id])
  end

  private

  def require_login
    unless current_user
      redirect_to login_path, alert: 'Veuillez-vous connecter pour accéder à cette page.'
    end
  end
end
