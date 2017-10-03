class UsersController < ApplicationController
  def index
    users = User.all
    render json: users, status: 200
  end

  def create
    user = User.create(email: filtered_params[:email])
    if user.persisted?
      render json: {}, status: 201
    else
      render json: { errors: 'Invalid email' }, status: 422
    end
  end

  def show
    begin
      user = User.find(filtered_params[:id])
      render json: user, status: 200
    rescue ActiveRecord::RecordNotFound
      render json: {}, status: 404
    end
  end

  def update
    begin
      user = User.find(filtered_params[:id])

      roles_id = filtered_params.delete :roles
      if roles_id.present?
        roles = Role.where id: roles_id
        user.roles << roles
        user.set_token
      end

      # TODO RSpec does not delete the :roles key from filtered_params
      user.update!(updating_params)
      render json: user, status: 200
    rescue ActiveRecord::RecordNotFound
      render json: {}, status: 404
    rescue ActiveRecord::RecordInvalid
      render json: { errors: 'Invalid email' }, status: 422
    end
  end

  def destroy
    begin
      User.destroy(filtered_params[:id])
      render json: {}, status: 204
    rescue ActiveRecord::RecordNotFound
      render json: {}, status: 404
    end
  end

  private

    def filtered_params
      params.permit(:id, :email, { roles: [] })
    end

    def updating_params
      params.permit(:id, :email)
    end
end
