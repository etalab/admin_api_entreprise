class AuthorizationRequest < ApplicationRecord
  validates :user, presence: true

  belongs_to :user
  has_one :token, required: false, foreign_key: 'authorization_request_model_id'

  validates :external_id, uniqueness: true, allow_blank: true

  has_many :contacts, dependent: :delete_all

  has_one :contact_technique, -> { where(contact_type: 'tech') }, class_name: 'Contact'
  has_one :contact_metier, -> { where(contact_type: 'admin') }, class_name: 'Contact'

  scope :submitted_at_least_once, -> { where.not(first_submitted_at: nil) }
end
