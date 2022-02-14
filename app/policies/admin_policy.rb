class AdminPolicy < ApplicationPolicy
  attr_reader :jwt_user

  def initialize(jwt_user, _record)
    @jwt_user = jwt_user
  end

  delegate :admin?, to: :jwt_user
end
