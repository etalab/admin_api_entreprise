class User::NotifyNewTokensOwner < ApplicationInteractor
  def call
    mailer_klass.transfer_ownership(context.current_owner, context.target_user, context.namespace).deliver_later
  end

  private

  def mailer_klass
    "#{context.namespace.classify}::UserMailer".constantize
  end
end
