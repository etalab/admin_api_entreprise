# TODO move it into app/models
class JwtUser
  attr_reader :id, :grants, :admin

  def initialize(uid:, grants:, admin: false, **)
    @id = uid
    @grants = grants
    @admin = admin
  end

  def admin?
    admin
  end

  def manage_token?
    grants.include?('token')
  end
end
