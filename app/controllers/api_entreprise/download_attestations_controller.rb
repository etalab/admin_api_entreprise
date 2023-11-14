class APIEntreprise::DownloadAttestationsController < APIEntreprise::AuthenticatedUsersController
  before_action :authorize!

  def new
    @tokens = extract_tokens
    @best_token = extract_best_token(@tokens)
  end

  # rubocop:disable Metrics/AbcSize
  def create
    token = Token.find(params[:token_id])
    @attestation_facade = EntrepriseWithAttestationsFacade.new(token:, siren: params[:siren])

    @attestation_facade.perform

    if @attestation_facade.success?
      respond_to do |format|
        format.turbo_stream { render 'create' }
        format.html { render 'create' }
      end
    else
      display_error(@attestation_facade.error)

      redirect_to attestations_path
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def authorize!
    authorize :download_attestations, :any?
  end

  def extract_tokens
    if params[:token_id].present?
      current_user.tokens.where(id: params[:token_id])
    else
      current_user.tokens.active_for('entreprise')
    end
  end

  def extract_best_token(tokens)
    tokens.max_by do |token|
      DownloadAttestationsPolicy.new(current_user, token).possible_attestations_count
    end
  end

  def display_error(error)
    flash_message(
      :error,
      title: 'Erreur lors de la recherche',
      description: error,
      id: 'error'
    )
  end
end
