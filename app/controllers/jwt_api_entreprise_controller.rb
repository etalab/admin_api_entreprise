class JwtApiEntrepriseController < ApplicationController
  def admin_create
    authorize :admin, :admin?
    result = JwtApiEntreprise::AdminCreate.call(params: params)

    if result.success?
      render json: { new_token: result[:created_token].rehash }, status: 201

    else
      errors = retrieve_errors(result)
      render json: { errors: errors }, status: 422
    end
  end

  def create
    raise Pundit::NotAuthorizedError unless pundit_user.id == params[:user_id]
    authorize JwtApiEntreprise

    # permit!.to_h is needed here because dry-validation needs params[:contact] to be a hash
    result = JwtApiEntreprise::UserCreate.call(params: params.permit!.to_h)

    if result.success?
      render json: { new_token: result[:created_token].rehash }, status: 201

    else
      errors = retrieve_errors(result)
      render json: { errors: errors }, status: 422
    end
  end

  def disable
    authorize :admin, :admin?

    jwt = JwtApiEntreprise.find params[:id]

    if jwt.update(enabled: false)
      render json: { message: 'Jwt disabled' }, status: :ok
    else
      render json: { error: 'Jwt still enabled' }, status: :unprocessable_entity
    end
  end

  private

  def retrieve_errors(operation_result)
    if operation_result['result.contract.default'].errors.empty?
      operation_result['manual_errors']
    else
      operation_result['result.contract.default'].errors
    end
  end
end
