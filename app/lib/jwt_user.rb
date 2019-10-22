# TODO: move it into app/models
class JwtUser
  attr_reader :id, :admin

  def initialize(uid:, admin: false, **)
    @id = uid
    @admin = admin
  end

  def admin?
    admin
  end
end
