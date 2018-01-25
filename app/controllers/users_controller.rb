class UsersController < ApplicationController
  skip_before_action :jwt_authenticate!, only: [:confirm]

  def index
    authorize :admin, :admin?
    users = User.all
    render json: users, each_serializer: UserIndexSerializer, status: 200
  end

  def create
    authorize :admin, :admin?
    result = User::Create.call(params)

    if result.success?
      render json: result['model'], status: 201

    else
      errors = result['result.contract.default'].errors.messages
      render json: { errors: errors }, status: 422
    end
  end

  def show
    user = User.find(params[:id])
    authorize user

    render json: user, serializer: UserShowSerializer, status: 200
  rescue ActiveRecord::RecordNotFound
    render json: {}, status: 404
  end

  def destroy
    authorize :admin, :admin?
    User.destroy(params[:id])
    render json: {}, status: 204
  rescue ActiveRecord::RecordNotFound
    render json: {}, status: 404
  end

  def confirm
    result = User::Confirm.call(params)

    if result.success?
      render json: {}, status: 200

    else
      # TODO handle errors from a generic application way
      errors = result['result.contract.params'].errors || result['errors']
      render json: { errors: errors }, status: 422
    end
  end
end
