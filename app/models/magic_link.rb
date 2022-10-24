class MagicLink < ApplicationRecord
  include RandomToken

  validates :email, presence: true, format: { with: /#{EMAIL_FORMAT_REGEX}/ }
  attribute :expiration_offset, default: -> { 4.hours.to_i }

  before_create :generate_random_token

  def generate_random_token
    self.random_token = random_token_for(:random_token)
  end

  def tokens(api: nil)
    TokensAssociatedToEmailQuery.new(email:, api:).call
  end

  def expiration_time
    created_at.to_time + expiration_offset
  end

  def expired?
    Time.zone.now >= expiration_time
  end
end
