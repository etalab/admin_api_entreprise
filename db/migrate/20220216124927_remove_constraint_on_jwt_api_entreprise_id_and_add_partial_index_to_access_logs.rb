class RemoveConstraintOnJwtAPIEntrepriseIdAndAddPartialIndexToAccessLogs < ActiveRecord::Migration[6.1]
  def change
    remove_column :access_logs, :jwt_api_entreprise_id
    add_column :access_logs, :jwt_api_entreprise_id, :uuid, null: true
    add_index :access_logs, :jwt_api_entreprise_id, where: 'jwt_api_entreprise_id IS NOT NULL'
  end
end
