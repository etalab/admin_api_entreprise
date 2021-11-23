class Admin::TokensController < AuthenticatedAdminsController
  def index
    @tokens = JwtAPIEntreprise.all
  end

  def show
    @token = JwtAPIEntreprise.find(token_params[:id])
    @user  = @token.user

    redirect_to admin_user_url(@user)
  end

  def blacklist
    @token = JwtAPIEntreprise.find(token_params[:id])
    @token.update_attribute(:blacklisted, true)

    @user  = @token.user

    redirect_to admin_user_url(@user)
  end

  def archive
    @token = JwtAPIEntreprise.find(token_params[:id])
    @token.update_attribute(:archived, true)

    @user  = @token.user

    redirect_to admin_user_url(@user)
  end

  def token_params
    params.permit(:id)
  end
end
