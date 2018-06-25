# TODO move it into app/models
class JwtUser
  attr_reader :id, :grants, :is_admin

  def initialize(uid:, grants:, admin: false, **)
    @id = uid
    @grants = grants
    @is_admin = admin
  end

  def admin?
    is_admin
  end

  def manage_token?
    grants.include?('token')
  end
end
