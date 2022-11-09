class AddRequestIdToAccessLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :access_logs, :request_id, :uuid, null: true
  end
end
