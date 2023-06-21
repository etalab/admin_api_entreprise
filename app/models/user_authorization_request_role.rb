class UserAuthorizationRequestRole < ApplicationRecord
  belongs_to :user, optional: false
  belongs_to :authorization_request, optional: false

  validates :authorization_request_id,
    uniqueness: { scope: %i[user_id role] }
  validates :user_id,
    uniqueness: { scope: %i[authorization_request_id role] }
  validates :role,
    uniqueness: { scope: %i[authorization_request_id user_id], case_sensitive: false },
    inclusion: { in: %w[demandeur contact_metier contact_technique] }

  belongs_to :demandeur,
    -> { joins(:user_authorization_request_roles).where(user_authorization_request_roles: { role: 'demandeur' }) },
    class_name: 'User',
    inverse_of: :user_authorization_request_roles,
    foreign_key: 'user_id',
    optional: true

  belongs_to :contact_metier,
    -> { joins(:user_authorization_request_roles).where(user_authorization_request_roles: { role: 'contact_metier' }) },
    class_name: 'User',
    inverse_of: :user_authorization_request_roles,
    foreign_key: 'user_id',
    optional: true

  belongs_to :contact_technique,
    -> { joins(:user_authorization_request_roles).where(user_authorization_request_roles: { role: 'contact_technique' }) },
    class_name: 'User',
    inverse_of: :user_authorization_request_roles,
    foreign_key: 'user_id',
    optional: true
end
