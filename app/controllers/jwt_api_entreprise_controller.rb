class JwtApiEntrepriseController < ApplicationController
  def index
    authorize :admin, :admin?

    jwt_list = JwtApiEntreprise.all
    render json: jwt_list, each_serializer: JwtApiEntrepriseIndexSerializer, status: 200
  end

  def create
    authorize :admin, :admin?
    result = JwtApiEntreprise::Operation::Create.call(params: params)

    if result.success?
      render json: { new_token: result[:model].rehash }, status: 201

    else
      errors = result['result.contract.default'].errors.messages
      render json: { errors: errors }, status: 422
    end
  end

  def update
    authorize :admin, :admin?

    update = JwtApiEntreprise::Operation::Update.call(params: update_params)

    if update.success?
      render json: {}, status: 200
    else
      render json: { errors: update[:errors] }, status: 422
    end
  end

  def magic_link
    result = JwtApiEntreprise::Operation::CreateMagicLink.call(
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

  private

  def update_params
    params.permit(:id, :blacklisted, :archived)
  end
end
