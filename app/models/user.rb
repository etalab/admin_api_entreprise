class User < ApplicationRecord
  has_many :contacts, dependent: :destroy
  has_many :tokens, dependent: :nullify

  validates :email, presence: true,
    uniqueness: true,
    format: { with: /\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\z/ }

  validates :user_type, presence: true,
    inclusion: { in: %w(client provider) }

  validates :context, presence: true,
    if: Proc.new { |u| u.user_type == 'client' }

  def create_token(payload)
    jwt_token = AccessToken.create payload
    new_token = Token.new(value: jwt_token)
    self.tokens << new_token
  end
end
