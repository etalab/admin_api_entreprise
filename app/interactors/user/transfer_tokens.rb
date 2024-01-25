class User::TransferTokens < ApplicationInteractor
  def call
    context.authorization_requests.each do |authorization_request|
      find_or_create_user_role(context.target_user, authorization_request)
      context.current_owner.user_authorization_request_roles.where(authorization_request:).delete_all
    end

    context.target_user.update(tokens_newly_transfered: true)
  end

  private

  def find_or_create_user_role(user, authorization_request)
    UserAuthorizationRequestRole.find_or_create_by(
      user_id: user.id,
      authorization_request_id: authorization_request.id,
      role: 'demandeur'
    )
  end
end
