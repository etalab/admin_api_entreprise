class TransferUserAccountController < AuthenticatedUsersController
  before_action :retrieve_user
  before_action :can_transfer?, only: :create

  def new
  end

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
      current_owner: @user,
      target_user_email: params[:email]
    }
  end

  def retrieve_user
    @user = User.find(params[:user_id])
  end

  def can_transfer?
    return true if current_user.id == @user.id || current_user.admin?

    head :forbidden

    false
  end
end
