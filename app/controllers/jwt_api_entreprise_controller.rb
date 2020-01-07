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

  def update
    authorize :admin, :admin?

    update = JwtApiEntreprise::Operation::Update.call(params: update_params)

    if update.success?
      render json: {}, status: 200
    else
      render json: { errors: update[:errors] }, status: 422
    end
  end

  private

  def update_params
    params.permit(:id, :blacklisted, :archived)
  end
end
