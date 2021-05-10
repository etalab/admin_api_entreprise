class RolesController < ApplicationController
  skip_before_action :jwt_authenticate!, only: [:index]

  def index
    roles = Role.all
    render(json: roles, status: 200)
  end

  def create
    authorize(:admin, :admin?)
    result = Role::Operation::Create.call(params: params)

    if result.success?
      render(json: result[:model], status: 201)

    else
      errors = result['result.contract.default'].errors
      render(json: { errors: errors }, status: 422)
    end
  end
end
