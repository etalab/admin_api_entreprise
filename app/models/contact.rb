class Contact < ApplicationRecord
  belongs_to :authorization_request
  has_many :tokens, through: :authorization_request
  has_one :valid_token, through: :authorization_request, source: :valid_token

  validates :email, presence: true, format: { with: /#{EMAIL_FORMAT_REGEX}/ }
  validates :contact_type, presence: true, inclusion: { in: %w[admin tech other] }

  def full_name
    "#{last_name.try(:upcase)} #{first_name}"
  end

  def token
    valid_token || tokens.first
  end

  scope :not_expired, lambda {
    joins(
      :tokens
    ).where(
      authorization_request: {
        tokens: {
          blacklisted: false,
          archived: false
        }
      }
    )
  }

  scope :with_tokens, -> { Contact.joins(authorization_request: :tokens) }
end
