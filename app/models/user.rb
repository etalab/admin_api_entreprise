class User < ApplicationRecord
  has_many :jwt_api_entreprise, dependent: :nullify
  has_many :contacts, through: :jwt_api_entreprise

  # Passing validations: false as argument so password can be blank on creation
  has_secure_password(validations: false)

  def confirmed?
    !!confirmed_at
  end

  def confirm
    return false if confirmed?

    self.confirmed_at = Time.now.utc
    save
  end

  def generate_confirmation_token
    update(confirmation_token: random_token_for(:confirmation_token))
  end

  def generate_pwd_renewal_token
    update(pwd_renewal_token: random_token_for(:pwd_renewal_token))
  end

  def encoded_jwt
    jwt_api_entreprise.where(blacklisted: false).map(&:rehash)
  end

  def blacklisted_jwt
    jwt_api_entreprise.where(blacklisted: true).map(&:rehash)
  end

  private

  def combine_roles_from_tokens
    roles = self.jwt_api_entreprise.reduce([]) { |result, jwt| result + jwt.access_roles }
    roles.uniq
  end

  def random_token_for(attr)
    constraint = {}
    loop do
      token = SecureRandom.hex(10)
      constraint[attr] = token
      return token unless User.find_by(constraint)
    end
  end
end
