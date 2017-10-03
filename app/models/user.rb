class User < ApplicationRecord
  has_and_belongs_to_many :roles

  validates :email, presence: true,
    format: { with: /\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+$\z/ }

  validates :token, presence: true

  before_validation :ensure_token_has_value

  def set_token
    # See JWT claims documentation
    iat = Time.now.to_i
    payload = { scope: get_scope, iat: iat }
    self.token = AccessToken.create payload
  end

  private

    def ensure_token_has_value
      set_token unless self.token.present?
    end

    def get_scope
      self.roles.map(&:name)
    end
end
