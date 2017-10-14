class RolesController < ApplicationController
  def index
    roles = Role.all
    render json: roles, status: 200
  end

  def create
    role = Role.create(filtered_params)
    if role.persisted?
      render json: role, status: 201
    else
      render json: { errors: 'Invalid role data' }, status: 422
    end
  end

  private

    def filtered_params
      params.permit :name, :code
    end
end
