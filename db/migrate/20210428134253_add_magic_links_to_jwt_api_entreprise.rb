class AddMagicLinksToJwtApiEntreprise < ActiveRecord::Migration[6.1]
  def change
    add_column :jwt_api_entreprises, :magic_link_token, :string, default: nil
    add_column :jwt_api_entreprises, :magic_link_issuance_date, :datetime, default: nil

    add_index :jwt_api_entreprises, :magic_link_token, unique: true
  end
end
