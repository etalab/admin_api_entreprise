class AttestationsController < AuthenticatedUsersController
  before_action :find_jwt,       only: %i[new search]
  before_action :find_jwt_roles, only: %i[new search]

  def index
    @user = current_user
  end

  def new
    return unless @jwt

    respond_to do |format|
      format.turbo_stream
    end
  end

  def search
    search = Siade.new(token: @jwt.rehash).entreprises(siret: params[:siret])
    @result = JSON.parse(search.body)

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  rescue RestClient::Unauthorized
    flash_message(:error, title: 'Erreur lors de la recherche', description: 'Non-autorisé')
    redirect_to profile_attestations_path
  end

  private

  def find_jwt
    return if params[:jwt_id].blank?

    @jwt = JwtAPIEntreprise.find(params[:jwt_id])
  end

  def find_jwt_roles
    @jwt_attestations_roles = @jwt.roles.select { |r| attestations_roles.include? r.code } if @jwt
  end

  def attestations_roles
    %w[attestations_sociales attestations_fiscales]
  end
end
