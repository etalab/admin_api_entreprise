class AttestationsController < AuthenticatedUsersController
  before_action :redirect_unless_authorized

  def index
    @jwts = current_user.jwt_api_entreprise

    @best_jwt = JwtRolesDecorator.best_jwt_to_retrieve_attestations(@jwts)
  end

  def new; end

  def search
    @jwt_roles_decorator = JwtRolesDecorator.new(jwt_id: params[:jwt_id])

    siade_search

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def siade_search
    @attestation_facade = EntrepriseWithAttestationsFacade.new(jwt: @jwt_roles_decorator.jwt, siret: params[:siret])
  rescue SiadeClientError => e
    handle_error!(e)
  end

  def redirect_unless_authorized
    redirect_to user_profile_path unless current_user.any_token_with_attestation_role?
  end

  def handle_error!(error)
    flash_message(:error,
      title: 'Erreur lors de la recherche',
      description: I18n.t(".attestations.search.error.#{error.code}"),
      id: "error-#{error.code}")

    redirect_to attestations_path
  end
end
