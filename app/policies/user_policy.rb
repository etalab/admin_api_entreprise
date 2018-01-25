class UserPolicy < ApplicationPolicy
  attr_reader :jwt_user

  def initialize(jwt_user, user)
    @jwt_user = jwt_user
    @user = user
  end

  def show?
    jwt_user.admin? || (jwt_user.id == @user.id)
  end
end
