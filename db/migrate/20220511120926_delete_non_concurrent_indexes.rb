class DeleteNonConcurrentIndexes < ActiveRecord::Migration[7.0]
  def change
    remove_index :access_logs, name: 'index_access_logs_on_params_siren'
    remove_index :access_logs, name: 'index_access_logs_on_params_siret'
    remove_index :access_logs, name: 'index_access_logs_on_params_siret_or_eori'
    remove_index :access_logs, name: 'index_access_logs_on_params_recipient'
    remove_index :access_logs, name: 'index_access_logs_on_jwt_api_entreprise_id'
  end
end
