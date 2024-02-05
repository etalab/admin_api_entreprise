module TransferUserAccountManagement
  extend ActiveSupport::Concern

  def new
    render 'shared/transfer_user_account/new'
  end

  def create
    transfer = User::TransferAccount.call(transfer_account_params)

    if transfer.success?
      success_message(title: t('shared.transfer_user_account.create.success.title'))

      redirect_to user_profile_path,
        status: :see_other
    else
      error_message(title: t('shared.transfer_user_account.create.error.title', target_email: t("#{namespace}.support_email")))

      render 'shared/transfer_user_account/new',
        status: :unprocessable_entity
    end
  end

  private

  def transfer_account_params
    {
      current_owner: current_user,
      target_user_email: params[:email],
      authorization_requests: current_user.authorization_requests.for_api(api),
      namespace:
    }
  end

  def api
    namespace.slice(4..-1)
  end
end
