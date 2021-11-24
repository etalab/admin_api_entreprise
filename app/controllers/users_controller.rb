class UsersController < AuthenticatedUsersController
  def profile
    @user = current_user
  end

  def transfer_account
    transfer = User::Operation::TransferOwnership.call(params: transfer_account_params)

    if transfer.success?
      success_message(title: t('.success.title'))
    else
      error_message(title: t('.error.title'))
    end

    redirect_back fallback_location: root_path
  end

  private

  def transfer_account_params
    {
      id: params[:id],
      email: params[:email],
    }
  end
end
