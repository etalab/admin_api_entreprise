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
    try_search
  rescue RestClient::Unauthorized
    handle_error!('Le token ne présente pas les autorisations nécessaires.')
  rescue RestClient::UnprocessableEntity
    handle_error!('Siret non valide.')
  rescue RestClient::NotFound
    handle_error!('Siret non trouvé.')
  end

  private

  def try_search
    search = Siade.new(token: @jwt.rehash).entreprises(siret: params[:siret])
    @result = JSON.parse(search.body)

    set_attestations_url if @result

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def set_attestations_url
    set_attestation_sociale_url if @jwt_attestations_roles.map(&:code).include? 'attestations_sociales'
    set_attestation_fiscale_url if @jwt_attestations_roles.map(&:code).include? 'attestations_fiscales'
  end

  def set_attestation_sociale_url
    response = Siade.new(token: @jwt.rehash).attestations_sociales(siren: siren)

    @url_attestation_sociale = JSON.parse(response.body)['url']
  end

  def set_attestation_fiscale_url
    response = Siade.new(token: @jwt.rehash).attestations_fiscales(siren: siren)

    @url_attestation_fiscale = JSON.parse(response.body)['url']
  end

  def handle_error!(msg)
    flash_message(:error, title: 'Erreur lors de la recherche', description: msg)
    redirect_to profile_attestations_path
  end

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

  def siren
    params[:siret].first(9)
  end
end
