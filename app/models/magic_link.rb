class MagicLink < ApplicationRecord
  DEFAULT_EXPIRATION_DELAY = 4.hours

  include RandomToken

  validates :email, presence: true, format: { with: /#{EMAIL_FORMAT_REGEX}/ }
  attribute :expires_at, default: -> { DEFAULT_EXPIRATION_DELAY.from_now }
  belongs_to :token, optional: true

  before_create :generate_random_token

  def generate_random_token
    self.random_token ||= random_token_for(:random_token)
  end

  def tokens(api: nil)
    return [token] if token.present?

    tokens_from_email(api:).to_a
  end

  def tokens_from_email(api: nil)
    TokensAssociatedToEmailQuery.new(email:, api:).call
  end

  def expired?
    Time.zone.now >= expires_at
  end
end
