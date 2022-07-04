class AccessLogsToTimestampWithZone < ActiveRecord::Migration[7.0]
  def up
    shared_action do
      change_column :access_logs, :timestamp, 'timestamp with time zone'
    end
  end

  def down
    shared_action do
      change_column :access_logs, :timestamp, :datetime
    end
  end

  private

  def shared_action
    # need to remove index in order to change column type
    remove_index :access_logs, name: "index_access_logs_on_params_recipient", if_exists: true
    remove_index :access_logs, name: "index_access_logs_on_params_siren", if_exists: true
    remove_index :access_logs, name: "index_access_logs_on_params_siret", if_exists: true
    remove_index :access_logs, name: "index_access_logs_on_params_siret_or_eori", if_exists: true
    remove_index :access_logs, name: "index_access_logs_on_timestamp_day", if_exists: true
    remove_index :access_logs, name: "index_access_logs_on_timestamp_hour", if_exists: true
    remove_index :access_logs, name: "index_access_logs_on_timestamp_month", if_exists: true
    remove_index :access_logs, name: "index_access_logs_on_timestamp_week", if_exists: true
    remove_index :access_logs, name: "index_access_logs_on_controller", if_exists: true
    remove_index :access_logs, name: "index_access_logs_on_status", if_exists: true
    remove_index :access_logs, name: "index_access_logs_on_timestamp", if_exists: true
    remove_index :access_logs, name: "index_access_logs_on_token_id", if_exists: true

    drop_view :access_logs_view

    yield

    create_view :access_logs_view, version: 4
  end
end
