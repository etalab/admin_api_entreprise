class User::NotifyDatapassOfTokenOwnership < ApplicationInteractor
  def call
    if first_login_after_token_transfer?
      UserMailer.notify_datapass_for_data_reconciliation(context.user).deliver_later
      context.user.update(tokens_newly_transfered: false)
    end
  end

  private

  def first_login_after_token_transfer?
    context.user.tokens_newly_transfered?
  end
end
