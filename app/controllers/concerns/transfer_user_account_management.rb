module TransferUserAccountManagement
  extend ActiveSupport::Concern

  def new
    render 'shared/transfer_user_account/new'
  end

  def create
    transfer = APIEntreprise::User::TransferAccount.call(transfer_account_params)

    if transfer.success?
      success_message(title: t('shared.transfer_user_account.create.success.title'))

      redirect_to user_profile_path,
        status: :see_other
    else
      error_message(title: t('shared.transfer_user_account.create.error.title'))

      render 'shared/transfer_user_account/new',
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
