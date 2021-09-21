class API::UsersController < APIController
  skip_before_action :jwt_authenticate!, only: [:password_renewal, :password_reset]

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

  def transfer_ownership
    user = User.find(params[:id])
    authorize user
    transfer = User::Operation::TransferOwnership.call(params: transfer_account_params)
    transfer_final_state = transfer.event.to_h[:semantic]

    case transfer_final_state
    when :success
      render json: transfer[:model], serializer: UserShowSerializer, status: 200
    when :invalid_params
      render json: { errors: transfer[:contract_errors] }, status: 422
    when :not_found
      msg = "Current owner account with ID `#{params[:id]}` does not exist."
      render json: { errors: msg }, status: 404
    end
  end

  private

  def user_params
    params.permit(:email, :context)
  end

  def transfer_account_params
    params.permit(:id, :email)
  end
end
