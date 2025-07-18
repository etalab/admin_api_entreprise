class AuthorizationRequest < ApplicationRecord
  belongs_to :organization,
    primary_key: :siret,
    foreign_key: :siret,
    inverse_of: :authorization_requests,
    optional: true,
    dependent: nil

  has_many :user_authorization_request_roles, dependent: :destroy do
    def for_user(user)
      where(user:)
    end
  end

  has_many :users, through: :user_authorization_request_roles, source: :user

  has_many :tokens,
    class_name: 'Token',
    foreign_key: 'authorization_request_model_id',
    inverse_of: :authorization_request,
    dependent: :destroy

  has_one :active_token, -> { active },
    class_name: 'Token',
    inverse_of: :authorization_request,
    required: false,
    foreign_key: 'authorization_request_model_id',
    dependent: :destroy

  validates :external_id, uniqueness: true, allow_blank: true

  validates :api, inclusion: { in: %w[entreprise particulier] }

  def self.ransackable_attributes(_)
    %w[
      siret
      external_id
      intitule
    ]
  end

  def self.ransackable_associations(_)
    %w[
      demandeur
    ]
  end

  scope :with_tokens_for, ->(api) { where(api:).joins(:tokens) }
  scope :submitted_at_least_once, -> { where.not(first_submitted_at: nil) }

  scope :not_archived, -> { where.not(status: 'archived') }
  scope :archived, -> { where(status: 'archived') }
  scope :for_api, ->(api) { where(api:) }
  scope :viewable_by_users, -> { where('status in (?) or validated_at is not null', %w[archived revoked validated]) }

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

  def prolong_token_expecting_updates?
    token&.last_prolong_token_wizard.present? &&
      token.last_prolong_token_wizard.requires_update?
  end
end
