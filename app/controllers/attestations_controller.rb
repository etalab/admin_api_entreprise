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

  private

  def attestations_roles
    %w[attestations_sociales attestations_fiscales]
  end
end
