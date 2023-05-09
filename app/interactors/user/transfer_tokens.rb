class User::TransferTokens < ApplicationInteractor
  def call
    context.current_owner.authorization_requests.each do |authorization_request|
      UserAuthorizationRequestRole.find_or_create_by(
        user_id: context.target_user.id,
        authorization_request_id: authorization_request.id,
        role: 'demandeur'
      )
    end

    context.current_owner.user_authorization_request_roles.clear

    context.target_user.update(tokens_newly_transfered: true)
  end
end
