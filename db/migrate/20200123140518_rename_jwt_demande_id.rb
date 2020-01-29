class RenameJwtDemandeId < ActiveRecord::Migration[6.0]
  def change
    rename_column :jwt_api_entreprises, :demande_id, :authorization_request_id
  end
end
