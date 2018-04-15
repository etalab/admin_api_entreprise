class AddContactToJwtApiEntreprise < ActiveRecord::Migration[5.1]
  def change
    add_reference :jwt_api_entreprises, :contact, foreign_key: true, type: :uuid, default: ''
  end
end
