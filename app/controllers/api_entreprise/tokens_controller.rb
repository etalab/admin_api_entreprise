class APIEntreprise::TokensController < APIEntreprise::AuthenticatedUsersController
  before_action :extract_token, except: %i[index]

  def index
    @active_tokens = current_user.tokens.active_for('entreprise').sort_by(&:exp).reverse
    authorization_requests = current_user.authorization_requests.with_tokens_for('entreprise')
    @inactive_tokens = authorization_requests.map(&:token).sort_by(&:exp).reverse - @active_tokens
  end

  def show; end

  def stats
    @stats_facade = TokenStatsFacade.new(@token)
  end

  def renew; end

  private

  def period_to_display
    params[:period]&.to_sym || :last_8_days
  end

  def extract_token
    @token = current_user.tokens.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    error_message(title: t('.error.title'))
    redirect_current_user_to_homepage
  end
end
