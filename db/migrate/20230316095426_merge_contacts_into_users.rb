class MergeContactsIntoUsers < ActiveRecord::Migration[7.0]
  class Contact < ApplicationRecord
    belongs_to :authorization_request
    has_many :tokens, through: :authorization_request
    has_one :active_token, through: :authorization_request, source: :active_token

    validates :email, presence: true, format: { with: /#{EMAIL_FORMAT_REGEX}/ }
    validates :contact_type, presence: true, inclusion: { in: %w[admin tech other] }

    def full_name
      "#{last_name.try(:upcase)} #{first_name}"
    end

    def token
      active_token || tokens.first
    end

    scope :not_expired, lambda {
      joins(
        :tokens
      ).where(
        authorization_request: {
          tokens: {
            blacklisted: false,
            archived: false
          }
        }
      )
    }

    scope :with_tokens, -> { Contact.joins(authorization_request: :tokens) }
  end

  def change
    create_table :user_authorization_request_roles, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid, index: false

      t.references :authorization_request, null: false, foreign_key: true, type: :uuid, index: false

      t.string :role, null: false

      t.timestamps
    end

    Contact.find_each do |contact|
      user = User.find_or_initialize_by(email: contact.email)

      user.update(
        first_name: contact.first_name,
        last_name: contact.last_name,
        phone_number: contact.phone_number,
        created_at: contact.created_at,
        updated_at: contact.updated_at
      )

      role = case contact.contact_type
             when :admin
               'contact_metier'
             when :tech
               'contact_technique'
             end

      role = 'demandeur' if user.persisted?

      user.save

      UserAuthorizationRequestRole.create!(user:, authorization_request: contact.authorization_request, role:) if contact.authorization_request
    end

    remove_column :authorization_requests, :user_id
    drop_table :contacts
  end
end
