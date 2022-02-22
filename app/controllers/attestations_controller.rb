class AttestationsController < AuthenticatedUsersController
  def index
    @user = current_user
  end

  def new
    return if params[:jwt_id].blank?

    jwt = JwtAPIEntreprise.find(params[:jwt_id])

    @jwt_attestations_roles = jwt.roles.select { |r| attestations_roles.include? r.code }

    respond_to do |format|
      format.turbo_stream
    end
  end

  def search
    jwt = JwtAPIEntreprise.find(params[:jwt_id])

    begin
      search = Siade.new(token: jwt.rehash).entreprises(siret: params[:siret])
    rescue RestClient::Unauthorized
      flash_message(:error, title: 'Erreur lors de la recherche', description: 'Non-autorisé')
      return redirect_to profile_attestations_path
    end

    @result = JSON.parse(search.body)
  end

  private

  def attestations_roles
    %w[attestations_sociales attestations_fiscales]
  end
end
