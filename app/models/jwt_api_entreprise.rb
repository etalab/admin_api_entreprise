class JwtApiEntreprise < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :roles

  def rehash
    AccessToken.create(token_payload)
  end

  private

  def token_payload
    {
      uid: self.user_id,
      jti: self.id,
      roles: self.roles.pluck(:code),
      sub: self.subject,
      iat: self.iat
    }
  end
end
