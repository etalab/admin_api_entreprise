module TokensManagement
  extend ActiveSupport::Concern

  def prolong
    token_facade = TokenManipulationFacade.new(@token, current_user)

    raise 'You are not allowed to prolong this token' unless token_facade.can_prolong?

    render 'shared/tokens/prolong'
  rescue StandardError
    redirect_current_user_to_homepage
  end

  def ask_for_extension
    authorize @token

    render 'shared/tokens/ask_for_extension'
  end

  def show
    authorize @token

    render 'shared/tokens/show'
  rescue Pundit::NotAuthorizedError
    render 'shared/tokens/cannot_show'
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
