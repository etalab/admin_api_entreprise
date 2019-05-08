class User < ApplicationRecord
  has_many :contacts, dependent: :destroy
  has_and_belongs_to_many :roles
  has_many :jwt_api_entreprise, dependent: :nullify

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
    token = ''
    loop do
      token = SecureRandom.hex(10)
      break unless User.find_by(confirmation_token: token)
    end
    self.confirmation_token = token
  end

  def encoded_jwt
    jwt_api_entreprise.where(blacklisted: false).map(&:rehash)
  end

  def blacklisted_jwt
    jwt_api_entreprise.where(blacklisted: true).map(&:rehash)
  end

  def manage_token?
    self.allow_token_creation
  end

  def allowed_roles
    if self.manage_token?
      self.roles.pluck(:code)
    else
      combine_roles_from_tokens
    end
  end

  private

  def combine_roles_from_tokens
    roles = self.jwt_api_entreprise.reduce([]) { |result, jwt| result + jwt.access_roles }
    roles.uniq
  end
end
