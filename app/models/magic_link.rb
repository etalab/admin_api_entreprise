class MagicLink < ApplicationRecord
  DEFAULT_EXPIRATION_DELAY = 24.hours

  validates :email, presence: true, format: { with: /#{EMAIL_FORMAT_REGEX}/ }
  attribute :expires_at, default: -> { DEFAULT_EXPIRATION_DELAY.from_now }
  belongs_to :token, optional: true
  scope :unexpired, -> { where('expires_at > ?', Time.zone.now) }

  before_create :generate_access_token

  def generate_access_token
    self.access_token ||= access_token_for(:access_token)
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

  def initial_expiration_delay_in_hours
    (expires_at - created_at).round / 3600
  end

  private

  def access_token_for(attr)
    constraint = {}
    loop do
      token = SecureRandom.hex(10)
      constraint[attr] = token
      return token unless self.class.find_by(constraint)
    end
  end
end
