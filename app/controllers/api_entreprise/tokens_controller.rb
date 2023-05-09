class APIEntreprise::TokensController < APIEntreprise::AuthenticatedUsersController
  def index
    @tokens = current_user.tokens.active_for('entreprise')
  end

  def show
    @token = Token.find(params[:id])

    return if access_allowed_for_current_user?

    error_message(title: t('.error.title'))
    redirect_current_user_to_homepage
  end

  def stats
    @token = Token.find(params[:id])
    @stats_facade = TokenStatsFacade.new(@token)
  end

  def renew
    @token = Token.find(params[:id])
  end

  private

  def period_to_display
    params[:period]&.to_sym || :last_8_days
  end

  def access_allowed_for_current_user?
    @token.users.include?(current_user)
  end
end
