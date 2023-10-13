class AuthorizationRequest < ApplicationRecord
  has_many :user_authorization_request_roles, dependent: :nullify
  has_many :users, through: :user_authorization_request_roles, source: :user

  has_many :tokens,
    class_name: 'Token',
    foreign_key: 'authorization_request_model_id',
    inverse_of: :authorization_request,
    dependent: :nullify

  has_one :active_token, -> { active },
    class_name: 'Token',
    inverse_of: :authorization_request,
    required: false,
    foreign_key: 'authorization_request_model_id',
    dependent: :nullify

  validates :external_id, uniqueness: true, allow_blank: true

  validates :api, inclusion: { in: %w[entreprise particulier] }

  scope :with_tokens_for, ->(api) { where(api:).joins(:tokens) }
  scope :submitted_at_least_once, -> { where.not(first_submitted_at: nil) }

  scope :not_archived, -> { where.not(status: 'archived') }
  scope :archived, -> { where(status: 'archived') }
  scope :for_api, ->(api) { where(api:) }

  def token
    active_token || most_recent_token
  end

  def most_recent_token
    tokens.order(exp: :desc).limit(1).first
  end

  has_many :contacts_authorization_request_roles,
    -> { where.not(role: 'demandeur') },
    class_name: 'UserAuthorizationRequestRole',
    inverse_of: :authorization_request,
    dependent: :destroy

  has_one :demandeur_authorization_request_role,
    -> { where(role: 'demandeur') },
    class_name: 'UserAuthorizationRequestRole',
    inverse_of: :authorization_request,
    dependent: :destroy

  has_one :contact_technique_authorization_request_role,
    -> { where(role: 'contact_technique') },
    class_name: 'UserAuthorizationRequestRole',
    inverse_of: :authorization_request,
    dependent: :destroy

  has_one :contact_metier_authorization_request_role,
    -> { where(role: 'contact_metier') },
    class_name: 'UserAuthorizationRequestRole',
    inverse_of: :authorization_request,
    dependent: :destroy

  has_many :contacts, through: :contacts_authorization_request_roles, source: :user
  has_one :demandeur, through: :demandeur_authorization_request_role
  has_one :contact_technique, through: :contact_technique_authorization_request_role
  has_one :contact_metier, through: :contact_metier_authorization_request_role

  def contacts_no_demandeur
    contacts.reject { |user| user == demandeur }
  end

  def archived?
    status == 'archived'
  end

  def archive!
    update!(status: 'archived')
  end

  def revoke!
    token&.update!(blacklisted_at: Time.zone.now)

    update!(status: 'revoked')
  end
end
