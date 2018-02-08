class JwtUser
  attr_reader :id

  def initialize(uid)
    @id = uid
  end

  def admin?
    id == Rails.application.secrets.fetch(:admin_uid)
  end
end
