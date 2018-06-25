# TODO move it into app/models
class JwtUser
  attr_reader :id, :grants

  def initialize(uid:, grants:, **)
    @id = uid
    @grants = grants
  end

  def admin?
    id == Rails.application.secrets.fetch(:admin_uid)
  end

  def manage_token?
    grants.include?('token')
  end
end
