class UsersController < ApplicationController
  def index
    users = User.all
    render json: users, status: 200
  end

  def create
    begin
      raise ActionController::ParameterMissing, 'Arguments missing' unless all_params_for_create?

      user = User.create(create_params)
      if user.persisted?
        render json: {}, status: 201
      else
        render json: { errors: 'Invalid email' }, status: 422
      end

    rescue ActionController::ParameterMissing
      render json: {}, status: 400
    end
  end

  def show
    begin
      user = User.find(params[:id])
      render json: user, status: 200
    rescue ActiveRecord::RecordNotFound
      render json: {}, status: 404
    end
  end

  def update
    begin
      raise ActionController::ParameterMissing, 'Arguments missing' unless has_updating_params?

      user = User.find(params[:id])
      user.update!(update_params)
      render json: user, status: 200

    rescue ActiveRecord::RecordNotFound
      render json: {}, status: 404

    rescue ActiveRecord::RecordInvalid
      render json: { errors: 'Invalid parameters' }, status: 422

    rescue ActionController::ParameterMissing
      render json: {}, status: 400
    end
  end

  def destroy
    begin
      User.destroy(params[:id])
      render json: {}, status: 204
    rescue ActiveRecord::RecordNotFound
      render json: {}, status: 404
    end
  end

  private

  def create_params
    params.permit %i(email context user_type)
  end

  def all_params_for_create?
    mandatory_params = %i(email context user_type)
    mandatory_params.all? { |e| create_params.has_key? e }
  end

  def update_params
    params.permit :email, :context
  end

  def has_updating_params?
    updating_params = %i(email context)
    updating_params.any? { |p| update_params.has_key? p }
  end
end
