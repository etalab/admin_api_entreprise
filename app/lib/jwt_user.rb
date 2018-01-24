class JwtUser
  attr_reader :id

  def initialize(uid)
    @id = uid
  end

  def admin?
    id == 'bacb9bbc-f208-4b23-a176-67504d4920dd'
  end
end
