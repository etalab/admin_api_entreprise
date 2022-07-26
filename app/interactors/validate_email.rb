class ValidateEmail < ApplicationInteractor
  def call
    fail!('invalid_email', 'warn') unless valid_email?
  end

  private

  def valid_email?
    context.email =~ ApplicationRecord::EMAIL_FORMAT_REGEX
  end
end
