class Contact < ApplicationRecord
  belongs_to :jwt_api_entreprise, optional: true
  scope :not_expired, -> { where(jwt_api_entreprises: { blacklisted: false, archived: false } ) }
end
