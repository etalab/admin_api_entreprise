class AuthorizationRequest < ApplicationRecord
  validates :user, presence: true

  belongs_to :user
  has_one :jwt_api_entreprise, required: false, foreign_key: 'authorization_request_model_id'

  has_many :contacts, dependent: :delete_all

  has_one :contact_technique, -> { where(contact_type: 'tech') }, class_name: 'Contact'
  has_one :contact_metier, -> { where(contact_type: 'admin') }, class_name: 'Contact'

  def all_contacts_have_different_emails?
    [
      user.email,
      contact_technique.email,
      contact_metier.email,
    ].uniq.count == 3
  end

  def all_contacts_have_the_same_email?
    [
      user.email,
      contact_technique.email,
      contact_metier.email,
    ].uniq.count == 1
  end
end
