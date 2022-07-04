class RestoreAccessLogsIndexes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :access_logs, :timestamp, algorithm: :concurrently, using: :brin
    add_index :access_logs, :controller, algorithm: :concurrently
    add_index :access_logs, :status, algorithm: :concurrently
    add_index :access_logs, "(params->>'siren')", using: :gin, name: 'index_access_logs_on_params_siren', algorithm: :concurrently
    add_index :access_logs, "(params->>'siret')", using: :gin, name: 'index_access_logs_on_params_siret', algorithm: :concurrently
    add_index :access_logs, "(params->>'siret_or_eori')", using: :gin, name: 'index_access_logs_on_params_siret_or_eori', algorithm: :concurrently
    add_index :access_logs, "(params->>'recipient')", using: :gin, name: 'index_access_logs_on_params_recipient', algorithm: :concurrently
    add_index :access_logs, :token_id, where: 'token_id IS NOT NULL', algorithm: :concurrently

    # indexes have to be on a fixed timezone
    add_index :access_logs, "date_trunc('hour',  timestamp at time zone 'Europe/Paris')", using: :brin, algorithm: :concurrently, name: 'index_access_logs_on_timestamp_hour'
    add_index :access_logs, "date_trunc('day',   timestamp at time zone 'Europe/Paris')", using: :brin, algorithm: :concurrently, name: 'index_access_logs_on_timestamp_day'
    add_index :access_logs, "date_trunc('week',  timestamp at time zone 'Europe/Paris')", using: :brin, algorithm: :concurrently, name: 'index_access_logs_on_timestamp_week'
    add_index :access_logs, "date_trunc('month', timestamp at time zone 'Europe/Paris')", using: :brin, algorithm: :concurrently, name: 'index_access_logs_on_timestamp_month'
  end
end
