module RandomToken
  private

  def access_token_for(attr)
    constraint = {}
    loop do
      token = SecureRandom.hex(10)
      constraint[attr] = token
      return token unless self.class.find_by(constraint)
    end
  end
end
