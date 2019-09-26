class UsersController < ApplicationController
  skip_before_action :jwt_authenticate!, only: [:confirm]

  def index
    authorize :admin, :admin?
    users = User.all
    render json: users, each_serializer: UserIndexSerializer, status: 200
  end

  def create
    authorize :admin, :admin?
    result = User::Operation::Create.call(params: params)

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

  def update
    authorize :admin, :admin?
    result = User::Operation::Update.call(params: params)

    if result.success?
      render json: result[:model], status: 200

    else
      render json: { errors: result[:errors] }, status: 422
    end
  end

  def destroy
    authorize :admin, :admin?
    User.destroy(params[:id])
    render json: {}, status: 204
  rescue ActiveRecord::RecordNotFound
    render json: {}, status: 404
  end

  def confirm
    result = User::Operation::Confirm.call(params: params)

    if result.success?
      render json: { access_token: result['access_token'] }, status: 200
    else
      render json: { errors: result['errors'] }, status: 422
    end
  end

  def add_roles
    authorize :admin, :admin?
    result = User::Operation::AddRoles.call(params: params)

    if result.success?
      render json: {}, status: 200

    else
      errors = result['result.contract.default'] || result['errors']
      render json: { errors: errors }, status: 422
    end
  end
end
