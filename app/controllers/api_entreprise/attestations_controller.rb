class APIEntreprise::AttestationsController < APIEntreprise::AuthenticatedUsersController
  before_action :authorize!

  def index
    @tokens = if params[:token_id].present?
                current_user.tokens.where(id: params[:token_id])
              else
                current_user.tokens.active_for('entreprise')
              end

    @best_token = attestations_scope_service.best_token_to_retrieve_attestations(@tokens)
  end

  def new; end

  def search
    @token = Token.find(params[:token_id])

    @attestation_facade = EntrepriseWithAttestationsFacade.new(token: @token, siren: siren_no_whitespaces)

    search_siade

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def search_siade
    handle_error(redirect: true) { @attestation_facade.retrieve_company }

    handle_error { @attestation_facade.retrieve_attestation_sociale }
    handle_error { @attestation_facade.retrieve_attestation_fiscale }
  end

  def handle_error(redirect: false)
    yield
  rescue SiadeClientError => e
    flash_error(e)
    redirect_to attestations_path if redirect
  end

  def authorize!
    authorize :attestation, :any?
  end

  def flash_error(error)
    flash_message(
      :error,
      title: 'Erreur lors de la recherche',
      description: error.message,
      id: "error-#{error.code}"
    )
  end

  def siren_no_whitespaces
    params[:siren].split.join
  end

  def attestations_scope_service
    @attestations_scope_service ||= AttestationsScopeService.new
  end
end
