class RolesController < ApplicationController
  def index
    roles = Role.all
    render json: roles, status: 200
  end

  def create
    role_form = RoleForm.new(Role.new)

    if role_form.validate(params)
      role_form.save
      render json: role_form.model, status: 201

    else
      render json: { errors: role_form.errors }, status: 422
    end
  end
end
