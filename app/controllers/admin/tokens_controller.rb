class Admin::TokensController < AdminController
  def index
    @user = User.find(params[:user_id])
    @tokens = @user.tokens.joins(:authorization_request).where(authorization_requests: { api: namespace }).order(created_at: :desc)
  end

  def ban
    @token = Token.find(params[:id])
    result = Admin::Tokens::Ban.call(token: @token, comment: params[:comment], namespace:)

    if result.success?
      success_message(title: 'Le token a été banni avec succès')
    else
      error_message(title: 'Une erreur est survenue lors du bannissement du token')
    end

    redirect_to admin_user_tokens_path(params[:user_id])
  end
end
