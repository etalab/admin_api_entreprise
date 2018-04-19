class JwtApiEntreprisePolicy < ApplicationPolicy
  def initialize(jwt_user, record)
    @jwt_user = jwt_user
    @record = record
  end

  def create?
    @jwt_user.manage_token?
  end
end
