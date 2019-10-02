class AdminPolicy < ApplicationPolicy
  attr_reader :jwt_user

  def initialize(jwt_user, _record)
    @jwt_user = jwt_user
  end

  def admin?
    jwt_user.admin?
  end
end
