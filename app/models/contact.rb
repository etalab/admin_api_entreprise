class Contact < ApplicationRecord
  self.ignored_columns = %w[
    jwt_api_entreprise_id
  ]

  belongs_to :authorization_request
  has_one :jwt_api_entreprise, through: :authorization_request

  validates :email, presence: true, format: { with: /#{EMAIL_FORMAT_REGEX}/ }
  validates :contact_type, presence: true, inclusion: { in: %w(admin tech other) }

  def full_name
    "#{last_name.try(:upcase)} #{first_name}"
  end

  scope :not_expired, lambda {
    joins(
      :jwt_api_entreprise,
    ).where(
      authorization_request: {
        jwt_api_entreprises: {
          blacklisted: false,
          archived: false
        }
      }
    )
  }
end
