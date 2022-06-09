class UserPolicy < ApplicationPolicy
  attr_reader :token_user

  def initialize(token_user, user_record)
    @token_user = token_user
    @user_record = user_record
  end

  def show?
    current_user?
  end

  def transfer_ownership?
    current_user?
  end

  private

  def current_user?
    token_user.id == @user_record.id
  end
end
