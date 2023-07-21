class User::NotifyNewTokensOwner < ApplicationInteractor
  def call
    APIEntreprise::UserMailer.transfer_ownership(context.current_owner, context.target_user).deliver_later
  end
end
