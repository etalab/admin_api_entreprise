class RolesController < ApplicationController
  def index
    authorize :admin, :admin?
    roles = Role.all
    render json: roles, status: 200
  end

  def create
    authorize :admin, :admin?
    result = Role::Create.call(params)

    if result.success?
      render json: result['model'], status: 201

    else
      errors = result['result.contract.default'].errors.messages
      render json: { errors: errors }, status: 422
    end
  end
end
