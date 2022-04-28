class CreateTimestampIndexes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :access_logs, "date_trunc('hour', timestamp)",  algorithm: :concurrently, name: 'index_access_logs_on_timestamp_hour'
    add_index :access_logs, "date_trunc('day', timestamp)",   algorithm: :concurrently, name: 'index_access_logs_on_timestamp_day'
    add_index :access_logs, "date_trunc('week', timestamp)",  algorithm: :concurrently, name: 'index_access_logs_on_timestamp_week'
    add_index :access_logs, "date_trunc('month', timestamp)", algorithm: :concurrently, name: 'index_access_logs_on_timestamp_month'
  end
end
