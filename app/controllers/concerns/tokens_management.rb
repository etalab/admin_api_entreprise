module TokensManagement
  extend ActiveSupport::Concern

  def prolong
    token_facade = TokenManipulationFacade.new(@token, current_user)

    raise 'You are not allowed to prolong this token' unless token_facade.can_prolong?

    render 'shared/tokens/prolong'
  rescue ActiveRecord::RecordNotFound
    error_message(title: t('.error.title'))

    redirect_current_user_to_homepage
  rescue StandardError
    redirect_current_user_to_homepage
  end

  private

  def extract_token
    @token = current_user.tokens.find(params[:id]).decorate
  rescue ActiveRecord::RecordNotFound
    error_message(title: t('.error.title'))
    redirect_current_user_to_homepage
  end
end
