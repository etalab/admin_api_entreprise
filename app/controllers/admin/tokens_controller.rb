class Admin::TokensController < AuthenticatedAdminsController
  if Rails.env.development?
    skip_before_action :authenticate_user!
    skip_before_action :authenticate_admin!
  end

  def index
    @tokens = JwtAPIEntreprise.all
  end
end
