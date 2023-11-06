module TokensManagement
  extend ActiveSupport::Concern

  def prolong
    authorize @token

    render 'shared/tokens/prolong'
  end

  def ask_for_prolongation
    authorize @token

    render 'shared/tokens/ask_for_prolongation'
  end

  def show
    authorize @token

    render 'shared/tokens/show'
  rescue Pundit::NotAuthorizedError
    render 'shared/tokens/cannot_show'
  end

  private

  def extract_token
    @token = current_user.tokens.find(params[:id]).decorate
  rescue ActiveRecord::RecordNotFound
    error_message(title: t('.error.title'))
    redirect_current_user_to_homepage
  end
end
