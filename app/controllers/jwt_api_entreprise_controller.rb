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

  private

  def retrieve_errors(operation_result)
    if operation_result['result.contract.params'].errors.empty?
      operation_result['manual_errors']
    else
      operation_result['result.contract.params'].errors
    end
  end
end
