class User < ApplicationRecord
  has_many :contacts, dependent: :destroy
  has_many :tokens, dependent: :nullify

  # Passing validations: false as argument so password can be blank on creation
  has_secure_password(validations: false)

  def confirmed?
    !!confirmed_at
  end
end
