class UsersController < ApplicationController
  skip_before_action :jwt_authenticate!, only: [:confirm, :password_renewal, :password_reset, :auth_api_gouv_token]

  def index
    authorize :admin, :admin?
    result = User::Operation::Index.call(params: user_params)
    if result.success?
      user_list = result[:user_list]
      render json: user_list, each_serializer: UserIndexSerializer, status: 200
    end
  end

  def create
    authorize :admin, :admin?
    result = User::Operation::Create.call(params: params)

    if result.success?
      render json: result[:model], serializer: UserShowSerializer, status: 201

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

  def password_reset
    result = User::Operation::ResetPassword.call(params: params)

    if result.success?
      render json: { access_token: result[:access_token] }, status: 200
    else
      render json: { errors: result['errors'] }, status: 422
    end
  end

  def password_renewal
    renewal_request = User::Operation::AskPasswordRenewal.call({ params: { email: params[:email] } })

    if renewal_request.success?
      render json: {}, status: 200
    else
      render json: { errors: renewal_request[:errors] }, status: 422
    end
  end

  def auth_api_gouv_token
    render json: 'yeah', status: 200
  end

  private

  def user_params
    params.permit(:email, :context)
  end
end
