class JwtAPIEntreprisePolicy < ApplicationPolicy
  attr_reader :jwt_user

  def initialize(jwt_user, jwt_record)
    @jwt_user = jwt_user
    @jwt_record = jwt_record
  end

  def magic_link?
    current_user_owns_jwt?
  end

  private

  def current_user_owns_jwt?
    jwt_user.id == @jwt_record.user.id
  end
end
