class Admin::Tokens::BansController < AdminController
  before_action :set_user
  before_action :set_token

  def new; end

  def create
    result = Admin::Tokens::Ban.call(ban_params)
    result.success? ? ban_success : ban_failure
    redirect_to admin_user_tokens_path(@user)
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_token
    @token = Token.find(params[:token_id])
  end

  def ban_params
    {
      token: @token,
      comment: params[:comment],
      blacklisted_at: parse_blacklisted_at,
      generate_new_token: params[:generate_new_token] == '1',
      namespace:,
      admin: current_user
    }
  end

  def parse_blacklisted_at
    params[:blacklisted_at].present? ? Time.zone.parse(params[:blacklisted_at]) : nil
  end

  def ban_success
    success_message(title: 'Le token a été banni avec succès')
  end

  def ban_failure
    error_message(title: 'Une erreur est survenue lors du bannissement du token')
  end
end
