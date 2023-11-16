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

  def stats
    @stats_facade = TokenStatsFacade.new(@token)

    render 'shared/tokens/stats'
  end

  private

  def extract_token
    @token = current_user.tokens.find(params[:id]).decorate
  end
end
