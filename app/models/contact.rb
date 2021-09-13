class Contact < ApplicationRecord
  belongs_to :authorization_request
  has_one :jwt_api_entreprise, through: :authorization_request

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
