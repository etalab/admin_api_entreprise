class RecreateAccessLogsIndexes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :access_logs, :timestamp, algorithm: :concurrently
    add_index :access_logs, :controller, algorithm: :concurrently
    add_index :access_logs, :status, algorithm: :concurrently
    add_index :access_logs, "(params->>'siren')", using: :gin, name: 'index_access_logs_on_params_siren', algorithm: :concurrently
    add_index :access_logs, "(params->>'siret')", using: :gin, name: 'index_access_logs_on_params_siret', algorithm: :concurrently
    add_index :access_logs, "(params->>'siret_or_eori')", using: :gin, name: 'index_access_logs_on_params_siret_or_eori', algorithm: :concurrently
    add_index :access_logs, "(params->>'recipient')", using: :gin, name: 'index_access_logs_on_params_recipient', algorithm: :concurrently
    add_index :access_logs, :jwt_api_entreprise_id, where: 'jwt_api_entreprise_id IS NOT NULL', algorithm: :concurrently
  end
end
