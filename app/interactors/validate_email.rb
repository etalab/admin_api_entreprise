class ValidateEmail < ApplicationInteractor
  def call
    fail!('invalid_email', 'warn', errors) unless valid_email?
  end

  private

  def valid_email?
    context.email_target_user = User.new(email: context.email)
    context.email_target_user.valid?
  end

  def errors
    context.email_target_user.errors.to_hash
  end
end
