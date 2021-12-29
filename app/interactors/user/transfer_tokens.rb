class User::TransferTokens < ApplicationInteractor
  def call
    context.target_user.authorization_requests << context.current_owner.authorization_requests
    context.current_owner.authorization_requests.clear

    context.target_user.update(tokens_newly_transfered: true)
  end
end
