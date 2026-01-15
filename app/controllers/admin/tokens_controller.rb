class Admin::TokensController < AdminController
  def index
    @user = User.find(params[:user_id])
    @tokens = @user.tokens.where(authorization_requests: { api: namespace }).uniq
  end
end
