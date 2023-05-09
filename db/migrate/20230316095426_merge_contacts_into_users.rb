class MergeContactsIntoUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :user_authorization_request_roles, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid, index: false

      t.references :authorization_request, null: false, foreign_key: true, type: :uuid, index: false

      t.string :role, null: false

      t.timestamps
    end

    ::Contact.find_each do |contact|
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
