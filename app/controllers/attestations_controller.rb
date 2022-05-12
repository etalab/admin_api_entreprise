class AttestationsController < AuthenticatedUsersController
  before_action :authorize!

  def index
    @jwts = current_user.token

    @best_jwt = Token.find_best_jwt_to_retrieve_attestations(@jwts)
  end

  def new; end

  def search
    @jwt = Token.find(params[:jwt_id]).decorate

    siade_search

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def siade_search
    @attestation_facade = EntrepriseWithAttestationsFacade.new(jwt: @jwt, siren: siren_no_whitespaces)
    @attestation_facade.retrieve_data
  rescue SiadeClientError => e
    handle_error!(e)
  end

  def authorize!
    authorize :attestation, :any?
  end

  def handle_error!(error)
    flash_message(
      :error,
      title: 'Erreur lors de la recherche',
      description: error.message,
      id: "error-#{error.code}"
    )

    redirect_to attestations_path
  end

  def siren_no_whitespaces
    params[:siren].split.join
  end
end
