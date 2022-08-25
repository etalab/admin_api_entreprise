class AuthorizationRequest < ApplicationRecord
  belongs_to :user

  has_one :token,
    foreign_key: 'authorization_request_model_id',
    required: false,
    inverse_of: :authorization_request,
    dependent: :nullify

  validates :external_id, uniqueness: true, allow_blank: true

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
end
