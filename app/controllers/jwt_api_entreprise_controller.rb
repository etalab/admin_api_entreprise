class JwtAPIEntrepriseController < AuthenticatedUsersController
  def index
    @tokens = current_user.jwt_api_entreprise
      .unexpired
      .not_blacklisted
      .where(archived: false)
  end

  def stats
    retrieve_stats = RetrieveTokenStats.call(token_id: params[:id])

    if retrieve_stats.success?
      @token = retrieve_stats.token
      @stats = retrieve_stats.stats
      @period = period_to_display
    else
      error_identifier = retrieve_stats.message
      error_message(title: t(".error.#{error_identifier}", token_id: params[:id]))
      redirect_to user_tokens_path if error_identifier == 'not_found'
    end
  end

  private

  def period_to_display
    params[:period]&.to_sym || :last_8_days
  end
end
