class AttestationsController < AuthenticatedUsersController
  before_action :authorize!

  def index
    @tokens = current_user.tokens

    @best_token = Token.find_best_token_to_retrieve_attestations(@tokens)
  end

  def new; end

  def search
    @token = Token.find(params[:token_id]).decorate

    siade_search

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def siade_search
    @attestation_facade = EntrepriseWithAttestationsFacade.new(token: @token, siren: siren_no_whitespaces)
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
