class Contact < ApplicationRecord
  self.ignored_columns = %w[
    token_id
  ]

  belongs_to :authorization_request
  has_one :token, through: :authorization_request

  validates :email, presence: true, format: { with: /#{EMAIL_FORMAT_REGEX}/ }
  validates :contact_type, presence: true, inclusion: { in: %w[admin tech other] }

  def full_name
    "#{last_name.try(:upcase)} #{first_name}"
  end

  scope :not_expired, lambda {
    joins(
      :token
    ).where(
      authorization_request: {
        tokens: {
          blacklisted: false,
          archived: false
        }
      }
    )
  }

  scope :with_token, -> { Contact.joins(authorization_request: :token) }
end
