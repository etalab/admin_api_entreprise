class User < ApplicationRecord
  has_many :contacts, dependent: :destroy
  has_many :tokens, dependent: :nullify

  def create_token(payload)
    jwt_token = AccessToken.create payload
    new_token = Token.new(value: jwt_token)
    self.tokens << new_token
  end
end
