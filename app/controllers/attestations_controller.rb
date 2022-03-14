class AttestationsController < AuthenticatedUsersController
  def index; end

  def new
    @jwt_facade = JwtFacade.new(jwt_id: params[:jwt_id])

    respond_to do |format|
      format.turbo_stream
    end
  end

  def search
    try_search
  # Faire heriter des erreurs dans les controller (meme une classe mère)
  rescue StandardError => e
    handle_error!(e)
  end

  private

  def try_search
    @jwt_facade = JwtFacade.new(jwt_id: params[:jwt_id])

    @attestation_facade = AttestationFacade.new(jwt: @jwt_facade.jwt, siret: params[:siret])

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def handle_error!(error)
    flash_message(:error, title: 'Erreur lors de la recherche', description: error.message)

    redirect_to profile_attestations_path
  end
end
