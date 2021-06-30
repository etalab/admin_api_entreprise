class JwtApiEntreprisePolicy < ApplicationPolicy
  attr_reader :jwt_user

  def initialize(jwt_user, jwt_record)
    @jwt_user = jwt_user
    @jwt_record = jwt_record
  end

  def magic_link?
    admin? || current_user_owns_jwt?
  end

  private

  def admin?
    jwt_user.admin?
  end

  def current_user_owns_jwt?
    jwt_user.id == @jwt_record.user.id
  end
end
