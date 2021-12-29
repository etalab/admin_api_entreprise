class User::NotifyNewTokensOwner < ApplicationInteractor
  def call
    UserMailer.transfer_ownership(context.current_owner, context.target_user).deliver_later
  end
end
