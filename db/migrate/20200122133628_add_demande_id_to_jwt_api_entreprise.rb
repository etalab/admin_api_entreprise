class AddDemandeIdToJwtApiEntreprise < ActiveRecord::Migration[6.0]
  def change
    add_column :jwt_api_entreprises, :demande_id, :string, default: nil
  end
end
