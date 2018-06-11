class JwtApiEntreprise < ApplicationRecord
  belongs_to :user
  belongs_to :contact, optional: true
  has_and_belongs_to_many :roles

  def rehash
    AccessToken.create(token_payload)
  end

  def access_roles
    self.roles.pluck(:code)
  end

  private

  def token_payload
    {
      uid: self.user_id,
      jti: self.id,
      roles: self.roles.pluck(:code),
      sub: self.subject,
      iat: self.iat,
      exp: self.exp
    }
  end
end
