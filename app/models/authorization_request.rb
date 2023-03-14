class AuthorizationRequest < ApplicationRecord
  belongs_to :user

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

  has_many :contacts, dependent: :destroy_async

  has_one :contact_technique,
    -> { where(contact_type: 'tech') },
    class_name: 'Contact',
    inverse_of: :authorization_request,
    dependent: :destroy

  has_one :contact_metier,
    -> { where(contact_type: 'admin') },
    class_name: 'Contact',
    inverse_of: :authorization_request,
    dependent: :destroy

  scope :submitted_at_least_once, -> { where.not(first_submitted_at: nil) }
  scope :authorization_requests_for, ->(api) { where(authorization_requests: { api: }) }

  def token
    active_token || tokens.first
  end
end
