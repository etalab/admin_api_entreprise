class JwtApiEntrepriseController < ApplicationController
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

  def blacklist
    authorize :admin, :admin?

    jwt = JwtApiEntreprise.find params[:id]

    if jwt.update(blacklisted: true)
      render json: { message: 'Jwt blacklisted' }, status: :ok
    else
      render json: { error: 'Jwt still active' }, status: :unprocessable_entity
    end
  end
end
