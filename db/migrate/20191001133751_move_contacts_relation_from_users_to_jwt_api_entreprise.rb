class MoveContactsRelationFromUsersToJwtAPIEntreprise < ActiveRecord::Migration[6.0]
  def change
    # Move existing data aside
    rename_table :contacts, :old_contacts

    # Create a new empty table for contacts with a foreign key to the JWT table
    create_table :contacts, id: :uuid do |t|
      t.string :email
      t.string :phone_number
      t.string :contact_type
      t.belongs_to :jwt_api_entreprise, foreign_key: true, type: :uuid, index: true
      t.timestamps
    end

    # Copy contact's data currently owned by users to their JWT (if the user
    # has multiple tokens contacts are just duplicated for each JWT)
    link_contacts_to_jwt

    # Check that the knew relations between contacts and JWT are valid and
    # fail (ie rollback the migration) if it's not the case
    fail('An error occured. Aborting...') unless new_relations_valid?

    # Drop old contacts table
    drop_table :old_contacts
  end

  def link_contacts_to_jwt
    JwtAPIEntreprise.all.each do |jwt|
      # Some JWT have no related user: this is a valid behaviour at the moment
      # When we destroy a user we keep a track of it's given JWT in base
      next if jwt.user.nil?

      contacts_data = query_contacts_for_user(jwt.user.id)
      if contacts_data.any?
        contacts_data.each do |data|
          jwt.contacts.create(
            email: data["email"],
            phone_number: data["phone_number"],
            contact_type: data["contact_type"],
            created_at: Time.zone.parse(data["created_at"] + ' UTC'),
            updated_at: Time.zone.parse(data["updated_at"] + ' UTC')
          )

          # A few words about the "+ UTC" trick above : timestamps a saved at
          # UTC in PostgreSQL (I guess Rails knows how to deal with timezones
          # on its own) so, when querying Postgre without ActiveRecord we got
          # timestamp as UTC, which are parsed in the Paris timezone by Rails
          # here. Then are saved with a 2 hours offset from the original
          # DateTime values... The issue has driven me crazy for more than one
          # hour, I even considered giving up the old timestamps values before
          # I found this trick. It's not pretty but, well, it does the job and
          # this will be used only once during the migration/
        end
      end
    end
  end

  # Here we check that if contacts were previously related to a user, they are
  # now related to a JWT of this same user.
  def new_relations_valid?
    User.all.each do |user|
      user_contacts = query_contacts_for_user(user.id)
      user.jwt_api_entreprise.each do |jwt|
        jwt_contacts = query_contacts_for_jwt(jwt.id)
        return false unless same_contacts?(user_contacts, jwt_contacts)
      end
    end
    true
  end

  def same_contacts?(contacts1, contacts2)
    return false unless contacts1.size == contacts2.size
    contacts1.each do |contact|
      return false unless contacts2.include?(contact)
    end
    true
  end

  # Those methods return an list of hashes, each element of the list being a
  # tuple from the  different contacts table.
  # E.g [{ "id": "dg12a-g3f", "email": "lol@lol.lol", "phone_number": ...}, ...]
  def query_contacts_for_user(user_id)
    query = "select email, phone_number, contact_type, created_at, updated_at from old_contacts where user_id = '#{user_id}';"
    result = ActiveRecord::Base.connection.execute(query)
    result.to_a
  end

  def query_contacts_for_jwt(jwt_id)
    query = "select email, phone_number, contact_type, created_at, updated_at from contacts where jwt_api_entreprise_id = '#{jwt_id}';"
    result = ActiveRecord::Base.connection.execute(query)
    result.to_a
  end
end
