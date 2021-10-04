class UsersController < AuthenticatedUsersController
  def profile
    @user = current_user
  end

  def transfer_account
    transfer = User::Operation::TransferOwnership.call(params: transfer_account_params)
    if transfer.success?
      flash[:notice] = 'Vos jetons ont été transférés avec succès.'
    else
      flash[:alert] = transfer[:contract_errors]
    end
    redirect_back fallback_location: root_path
  end

  private

  def transfer_account_params
    {
      id: current_user.id,
      email: params[:email],
    }
  end
end
