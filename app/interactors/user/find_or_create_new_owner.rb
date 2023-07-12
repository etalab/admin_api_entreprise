class User::FindOrCreateNewOwner < ApplicationInteractor
  def call
    context.target_user = User.find_or_initialize_by_email(context.target_user_email)
    fail!('invalid_email', 'warn', errors) unless context.target_user.save
  end

  private

  def errors
    context.target_user.errors.to_hash
  end
end
