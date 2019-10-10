class JwtApiEntrepriseController < ApplicationController
  def admin_create
    authorize :admin, :admin?
    result = JwtApiEntreprise::Operation::AdminCreate.call(params: params)

    if result.success?
      render json: { new_token: result[:created_token].rehash }, status: 201

    else
      errors = retrieve_errors(result)
      render json: { errors: errors }, status: 422
    end
  end

  def blacklist
    authorize :admin, :admin?

    jwt = JwtApiEntreprise.find(params[:id])

    if jwt.update(blacklisted: true)
      render json: { message: 'Jwt blacklisted' }, status: :ok
    else
      render json: { error: 'Jwt still active' }, status: :unprocessable_entity
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
