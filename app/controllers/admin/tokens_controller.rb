class Admin::TokensController < AuthenticatedAdminsController
  def index
    @tokens = JwtAPIEntreprise.all
  end

  def show
    @token = JwtAPIEntreprise.find(params[:id])
    @user  = @token.user

    redirect_to admin_user_path(@user)
  end

  def blacklist
    @token = JwtAPIEntreprise.find(params[:id])
    @token.update(blacklisted: true)

    @user  = @token.user

    info_message(title: t('.alert', token_subject: @token.displayed_subject))
    redirect_to admin_user_path(@user)
  end

  def archive
    @token = JwtAPIEntreprise.find(params[:id])
    @token.update(archived: true)

    @user  = @token.user

    info_message(title: t('.alert', token_subject: @token.displayed_subject))
    redirect_to admin_user_path(@user)
  end
end
