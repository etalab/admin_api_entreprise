class APIEntreprise::TransferUserAccountController < APIEntreprise::AuthenticatedUsersController
  def new; end

  def create
    transfer = User::TransferAccount.call(transfer_account_params)

    if transfer.success?
      success_message(title: t('.success.title'))

      redirect_to user_profile_path,
        status: :see_other
    else
      error_message(title: t('.error.title'))

      render 'new',
        status: :unprocessable_entity
    end
  end

  private

  def transfer_account_params
    {
      current_owner: current_user,
      target_user_email: params[:email]
    }
  end
end
