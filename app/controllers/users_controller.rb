class UsersController < AuthenticatedUsersController
  def profile
    @user = current_user
  end

  def transfer_account
    if transfer_allowed_for_current_user?
      transfer = User::TransferAccount.call(transfer_account_params)

      if transfer.success?
        success_message(title: t('.success.title'))
      else
        error_message(title: t('.error.title'))
      end

      redirect_back fallback_location: root_path
    else
      head :forbidden
    end
  end

  private

  def transfer_account_params
    {
      current_owner: current_account_owner,
      target_user_email: params[:email],
    }
  end

  def transfer_allowed_for_current_user?
    current_user.id == params[:id] ||
      current_user.admin?
  end

  def current_account_owner
    User.find(params[:id])
  end
end
