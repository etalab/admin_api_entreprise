class User < ApplicationRecord
  has_and_belongs_to_many :roles

  validates :email, presence: true,
    format: { with: /\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+$\z/ }

  validates :token, presence: true

  before_validation :ensure_token_has_value

  private

    def ensure_token_has_value
      unless self.token.present?
        self.token = 'temporarytoken'
      end
    end
end
