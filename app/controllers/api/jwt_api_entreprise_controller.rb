class API::JwtAPIEntrepriseController < APIController
  skip_before_action :jwt_authenticate!, only: [:show_magic_link]

  def index
    authorize :admin, :admin?

    jwt_list = JwtAPIEntreprise.all
    render json: jwt_list, each_serializer: JwtAPIEntrepriseIndexSerializer, status: 200
  end

  def update
    authorize :admin, :admin?

    update = JwtAPIEntreprise::Operation::Update.call(params: update_params)

    if update.success?
      render json: {}, status: 200
    else
      render json: { errors: update[:errors] }, status: 422
    end
  end

  def create_magic_link
    result = JwtAPIEntreprise::Operation::CreateMagicLink.call(
      params: params,
      current_user: pundit_user,
    )

    if result.success?
      render json: {}, status: 200
    else
      state = result.event.to_h[:semantic]

      if state == :not_found
        render json: { errors: { id: ["JWT with id #{params[:id]} is not found."] } }, status: 404
      elsif state == :invalid_params
        errors = result['result.contract.default'].errors
        render json: { errors: errors }, status: 422
      elsif state == :unauthorized
        render json: { errors: 'Unauthorized' }, status: 403
      end
    end
  end

  def show_magic_link
    result = JwtAPIEntreprise::Operation::RetrieveFromMagicLink.call(params: params)

    if result.success?
      render json: result[:jwt], serializer: JwtAPIEntrepriseShowSerializer, status: 200
    else
      render json: { errors: { token: ['not a valid token'] } }, status: 404
    end
  end

  private

  def update_params
    params.permit(:id, :blacklisted, :archived)
  end
end
