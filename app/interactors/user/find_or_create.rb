class User::FindOrCreate < ApplicationInteractor
  def call
    context.target_user = User.find_or_initialize_by_email(context.target_user_email)
    context.target_user.context = context.current_owner.context
    fail!('invalid_email', 'warn', errors) unless context.target_user.save
  end

  private

  def errors
    context.target_user.errors.to_hash
  end
end
