class User < ApplicationRecord
  has_many :jwt_api_entreprise, dependent: :nullify
  has_many :contacts, through: :jwt_api_entreprise

  # Passing validations: false as argument so password can be blank on creation
  has_secure_password(validations: false)

  def confirmed?
    !!oauth_api_gouv_id
  end

  def tokens_newly_transfered?
    tokens_newly_transfered
  end

  def generate_pwd_renewal_token
    update(pwd_renewal_token: random_token_for(:pwd_renewal_token))
  end

  private

  def random_token_for(attr)
    constraint = {}
    loop do
      token = SecureRandom.hex(10)
      constraint[attr] = token
      return token unless User.find_by(constraint)
    end
  end
end
