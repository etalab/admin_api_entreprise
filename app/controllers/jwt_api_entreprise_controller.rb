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
    else
      error_message(title: t('.error.title'), description: retrieve_stats.message)
      redirect_to user_tokens_path
    end
  end
end
