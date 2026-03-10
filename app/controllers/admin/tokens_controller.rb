class Admin::TokensController < AdminController
  before_action :set_user

  def index
    @tokens = @user.tokens.where(authorization_requests: { api: namespace }).uniq
  end

  def new
    @authorization_requests = @user.authorization_requests.where(api: namespace).eligible_for_token_creation
    @default_expiration = 18.months.from_now.to_date
  end

  def create
    result = Admin::Tokens::Create.call(
      authorization_request: @user.authorization_requests.eligible_for_token_creation.find(params[:authorization_request_id]),
      exp_date: params[:exp],
      admin: current_user
    )

    if result.success?
      success_message(title: 'Le jeton a été créé avec succès')
    else
      error_message(title: result.message)
    end

    redirect_to admin_user_tokens_path(@user)
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
