class TokenPolicy < ApplicationPolicy
  attr_reader :token_user

  def initialize(token_user, token_record)
    @token_user = token_user
    @token_record = token_record
  end

  def magic_link?
    current_user_owns_token?
  end

  private

  def current_user_owns_token?
    token_user.id == @token_record.user.id
  end
end
