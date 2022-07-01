class UpdateAccessLogsViewToVersion4 < ActiveRecord::Migration[7.0]
  def change
    update_view :access_logs_view, version: 4, revert_to_version: 3
  end
end
