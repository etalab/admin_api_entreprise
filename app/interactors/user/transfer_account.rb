class User::TransferAccount < ApplicationInteractor
  def call
    find_or_build_target_user
    transfer_tokens
    send_email_to_new_owner
  end

  private

  def errors
    context.target_user.errors.to_hash
  end

  def find_or_build_target_user
    context.target_user = User.find_or_initialize_by_email(context.target_user_email)
    context.target_user.context = context.current_owner.context
    fail!('invalid_email', 'warn', errors) unless context.target_user.save
  end

  def transfer_tokens
    context.target_user.authorization_requests << context.current_owner.authorization_requests
    context.current_owner.authorization_requests.clear

    context.target_user.update(tokens_newly_transfered: true)
  end

  def send_email_to_new_owner
    UserMailer.transfer_ownership(context.current_owner, context.target_user).deliver_later
  end
end
