class Token < ApplicationRecord
  belongs_to :user

  validates :value, presence: true,
    # base64url format separated by dots
    format: { with: /\A([a-zA-Z0-9_=-]+\.){2}[a-zA-Z0-9_=-]+\z/ }
end
