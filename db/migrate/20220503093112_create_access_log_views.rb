class CreateAccessLogViews < ActiveRecord::Migration[7.0]
  def change
    drop_view   :access_logs_view
    create_view :access_logs_view
  end
end
